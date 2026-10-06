# TipTap::Schema

`TipTap::Schema` is the canonical registry of **node** and **mark** type names → Ruby classes.
Parsing (`Document.from_json` / `Node.from_json`) resolves each JSON node `type` through a schema.
`Text` resolves mark `type` values through the same schema when rendering HTML/Markdown.

## Default schema

Loading the gem builds registrations into `TipTap.default_schema` via each node's or mark's
`self.type_name = "..."` . Built-in nodes (`doc`, `paragraph`, `text`, …) and marks
(`bold`, `italic`, `link`, …) live there.

```ruby
TipTap.default_schema.node_for("paragraph") # => TipTap::Nodes::Paragraph
TipTap.node_for("paragraph")                # same

TipTap.default_schema.mark_for("bold")      # => TipTap::Marks::Bold
TipTap.mark_for("bold")                     # same
```

## Registry compatibility

`TipTap::Registry` is a thin façade over `TipTap.default_schema`:

| Registry API | Delegates to |
| --- | --- |
| `Registry.register(name, klass)` | `TipTap.default_schema.register` |
| `Registry.node_for(name)` | `TipTap.default_schema.node_for` |
| `Registry.register_mark(name, klass)` | `TipTap.default_schema.register_mark` |
| `Registry.mark_for(name)` | `TipTap.default_schema.mark_for` |
| `Registry.clear` | `TipTap.default_schema.clear` (nodes **and** marks) |
| `Registry.registry` | `TipTap.default_schema.nodes` |

`Registry::MissingNodeError` / `MissingMarkError` alias the Schema error classes.

Prefer `Schema` for new code; keep using `Registry` if you already depend on it.

## Custom nodes

### Register on the default schema (global)

```ruby
class MyCallout < TipTap::Node
  self.type_name = "callout" # auto-registers on TipTap.default_schema
  self.html_tag = :aside
end

# or explicitly:
TipTap.default_schema.register("callout", MyCallout)
# TipTap::Registry.register("callout", MyCallout) # equivalent
```

### Isolated schema (recommended for app-specific nodes)

```ruby
schema = TipTap::Schema.new.use(TipTap.default_schema)
schema.register("callout", MyCallout)

document = TipTap::Document.from_json(json, schema: schema)
```

Isolated schemas do not affect other parses that use the default schema.
`use` copies the default schema's node and mark registrations into the new schema.

## Custom marks

Marks subclass `TipTap::Mark` and implement `wrap_html` / `wrap_markdown`.
`html_priority` / `markdown_priority` control nesting order (lower = applied first = innermost).

### Global registration

```ruby
class Spoiler < TipTap::Mark
  self.type_name = "spoiler"
  self.html_priority = 55

  def wrap_html(value)
    content_tag(:span, value, class: "spoiler")
  end

  def wrap_markdown(value, context: nil)
    "||#{value}||"
  end
end
```

### Isolated schema

```ruby
schema = TipTap::Schema.new.use(TipTap.default_schema)
schema.register_mark("spoiler", Spoiler)

text = TipTap::Nodes::Text.new("secret", marks: [{type: "spoiler"}], schema: schema)
text.to_html # => <span class="spoiler">secret</span>

# Builder API unchanged — marks stay TipTap-shaped hashes in to_h:
text.to_h # => { type: "text", text: "secret", marks: [{ type: "spoiler" }] }
```

Unknown mark types on a schema are ignored during rendering but still appear in `to_h`.

## Composing schemas

```ruby
schema = TipTap::Schema.new
schema.use(TipTap.default_schema) # copy built-in nodes and marks
schema.register("callout", MyCallout)
schema.register_mark("spoiler", Spoiler)

# or an extension object:
module CalloutExtension
  def self.register(schema)
    schema.register("callout", MyCallout)
    schema.register_mark("spoiler", Spoiler)
  end
end

schema.use(CalloutExtension)
```


## Parent builders

Child node classes declare which parents get a builder method via `parent_builder`.
Registration (`type_name=` / `Schema#register`) installs those methods onto the parents
through an included module (idempotent; no hand-edited parent source required).

```ruby
class Callout < TipTap::Node
  self.type_name = "callout"
  self.html_tag = :aside

  parent_builder on: TipTap::Document, as: :callout, require_block: true
  # args: {level: 1}     → default kwargs
  # args: [:src]         → required keywords
end

document.callout { |c| … }
```

Parents may be Class objects or fully qualified strings (for load-order safety).
`TipTap.install_parent_builders!` runs at gem load to resolve forward references.

Leaf builders (no block):

- `paragraph.hard_break` / `heading.hard_break` → `hardBreak`
- `document.horizontal_rule` → `horizontalRule`

### Still special-cased (not parent_builder)

- `Paragraph#text` / `Heading#text` — positional text + marks
- `Codeblock#code` — builds a `Text` node with a code mark


## Unknown nodes

By default, parsing raises `Schema::MissingNodeError` for unregistered types (backward compatible).

Opt into passthrough so unknown nodes are kept as `TipTap::Nodes::Unknown` (original type,
attrs, and recursively parsed content) for `to_h` round-trips:

```ruby
# Schema-level
schema = TipTap::Schema.new.use(TipTap.default_schema)
schema.unknown_node = :passthrough  # or :raise (default)
document = TipTap::Document.from_json(json, schema: schema)

# Per-call override (does not mutate the schema)
document = TipTap::Document.from_json(json, unknown_node: :passthrough)
```

`Unknown#to_html` / `#to_markdown` / `#to_plain_text` render **children only** (no wrapper tag).

## Heading TOC ids

Headings may carry `id` and `data-toc-id` for table-of-contents links.

- **Preserve:** values from JSON/attrs are kept (never overwritten on parse).
- **Generate when missing (default):** `Heading.new` and `from_json` fill both attrs with a UUID when absent.
- **Opt out:** `Heading.new(..., generate_toc_ids: false)` or `Document.from_json(json, generate_toc_ids: false)`.

