# Tiptap

A gem for parsing, generating, and rendering TipTap Documents and Nodes using Ruby.

## Note

This gem is under active development and is changing somewhat quickly. There is a chance that there may be breaking changes until a stable version is released.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tiptap-ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tiptap-ruby

## Usage

### Parsing a TipTap Document

You can parse a TipTap Document so that you can interact with it to do things such as add content (Nodes) or render it as HTML, JSON, or plain text:

```ruby
document = TipTap::Document.from_json(tiptap_json)
```

### Generate a New Document

```ruby
document = TipTap::Document.new
```

You can also pass a block and the new Document will be yielded to the block.

```ruby
TipTap::Document.new do |document|
  # Do something with document
end
```

### Add Content to the Document

Now that you have a Document you can add content to it.

```ruby
document.heading(level: 1) do |heading|
  heading.text("My Import Document", marks: [{type: "italic"}])
end
```

Built-in builders (heading, paragraph, lists, table, `hard_break`, `horizontal_rule`, and so on) are declared on each node via `parent_builder`. See `lib/tip_tap/nodes/` or [docs/schema.md](docs/schema.md).

### Generate Output

Once you have a Document with some content you can render it to HTML, JSON, and plain text.

#### JSON

```ruby
document.to_h # => { type: 'doc', content: […nodes]}
```

### HTML

```ruby
document.to_html # => <div class="tiptap-document"><h1><em>My Important Document</em></h1></div>
```

### Markdown

Generate GitHub-flavored Markdown that preserves nested lists, code blocks, tables, and inline marks.

```ruby
document.to_markdown # => "# My Important Document\n\n- Item one\n- Item two"
```

### Plain Text

Rendering to plain text is useful if you want to search the contents of your TipTap content.

```ruby
document.to_plain_text # => My Important Document
```

### Custom Nodes

Node types are registered on a `TipTap::Schema` (the default schema is populated when the gem loads). Setting `type_name` registers the class for parsing; declare `parent_builder` so parents get a fluent builder—no monkey-patching required.

```ruby
# lib/tip_tap/nodes/gallery.rb

module TipTap
  module Nodes
    class Gallery < Node
      self.type_name = "gallery" # registers on TipTap.default_schema
      self.html_tag = :div
      self.html_class_name = "gallery"

      parent_builder on: TipTap::Document, as: :gallery, require_block: true
    end

    class GalleryItem < Node
      self.type_name = "galleryItem"
      self.html_tag = :div

      parent_builder on: Gallery, as: :gallery_item, args: [:src]
    end
  end
end
```

Require your nodes (for example from an initializer), then build as usual:

```ruby
require "tip_tap/nodes/gallery"

document = TipTap::Document.new
document.gallery do |gallery|
  gallery.gallery_item(src: "https://example.com/photo.jpg")
end

# Parsing also resolves the custom type via the schema:
TipTap::Document.from_json(document.to_h)
```

#### Isolated schema (recommended for app-specific types)

To avoid registering globally on `TipTap.default_schema`, duplicate the default schema and register there:

```ruby
schema = TipTap.default_schema.dup
schema.register("gallery", TipTap::Nodes::Gallery)
schema.register("galleryItem", TipTap::Nodes::GalleryItem)

document = TipTap::Document.from_json(json, schema: schema)
```

`TipTap::Registry` still works; it is a thin façade over the default schema. Prefer `Schema` for new code.

#### Custom marks

Inline marks work the same way with `TipTap::Mark` and `register_mark` / `self.type_name =`. See [docs/schema.md](docs/schema.md) for marks, unknown-node passthrough, and Heading TOC id options.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle install`.

To release a new version, update the version number in `version.rb`, and then run `bin/release` or `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CompanyCam/tiptap-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
