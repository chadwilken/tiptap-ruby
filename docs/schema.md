# TipTap::Schema

`TipTap::Schema` is the canonical registry of node type names → Ruby classes.
Parsing (`Document.from_json` / `Node.from_json`) resolves each JSON `type` through a schema.

## Default schema

Loading the gem builds registrations into `TipTap.default_schema` via each node's
`self.type_name = "..."` (see `TipTap::Registerable`). Built-ins (`doc`, `paragraph`,
`text`, lists, tables, etc.) live there.

```ruby
TipTap.default_schema.node_for("paragraph") # => TipTap::Nodes::Paragraph
TipTap.node_for("paragraph")                # same, via default schema
```

## Registry compatibility

`TipTap::Registry` is a thin façade over `TipTap.default_schema`:

| Registry API | Delegates to |
| --- | --- |
| `Registry.register(name, klass)` | `TipTap.default_schema.register` |
| `Registry.node_for(name)` | `TipTap.default_schema.node_for` |
| `Registry.clear` | `TipTap.default_schema.clear` |
| `Registry.registry` | `TipTap.default_schema.nodes` |

`Registry::MissingNodeError` is an alias of `Schema::MissingNodeError`.

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
schema = TipTap.default_schema.dup
schema.register("callout", MyCallout)

document = TipTap::Document.from_json(json, schema: schema)
```

Isolated schemas do not affect other parses that use the default schema.

## Composing schemas

```ruby
schema = TipTap::Schema.new
schema.use(TipTap.default_schema) # copy built-ins
schema.register("callout", MyCallout)

# or an extension object:
module CalloutExtension
  def self.register(schema)
    schema.register("callout", MyCallout)
  end
end

schema.use(CalloutExtension)
```

## Marks

Mark handling is unchanged in this phase; schema registration for marks comes later.
