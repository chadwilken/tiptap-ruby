# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Mark do
  describe "built-in registration" do
    it "registers all built-in marks on the default schema" do
      schema = TipTap.default_schema

      {
        "bold" => TipTap::Marks::Bold,
        "italic" => TipTap::Marks::Italic,
        "underline" => TipTap::Marks::Underline,
        "strike" => TipTap::Marks::Strike,
        "code" => TipTap::Marks::Code,
        "link" => TipTap::Marks::Link,
        "textStyle" => TipTap::Marks::TextStyle,
        "superscript" => TipTap::Marks::Superscript,
        "subscript" => TipTap::Marks::Subscript,
        "highlight" => TipTap::Marks::Highlight
      }.each do |name, klass|
        expect(schema.mark_for(name)).to eq(klass)
        expect(TipTap.mark_for(name)).to eq(klass)
      end
    end
  end

  describe ".from_hash / #to_h" do
    it "round-trips attrs" do
      mark = TipTap::Marks::Link.from_hash(
        "type" => "link",
        "attrs" => {"href" => "https://example.com", "target" => "_blank"}
      )

      expect(mark.href).to eq("https://example.com")
      expect(mark.to_h).to eq({
        type: "link",
        attrs: {href: "https://example.com", target: "_blank"}
      })
    end
  end
end

RSpec.describe "custom marks via Schema" do
  let(:spoiler_mark) do
    Class.new(TipTap::Mark) do
      def self.type_name
        "spoiler"
      end

      self.html_priority = 55
      self.markdown_priority = 5

      def wrap_html(value)
        content_tag(:span, value, class: "spoiler")
      end

      def wrap_markdown(value, context: nil)
        "||#{value}||"
      end
    end
  end

  it "renders a custom mark registered on an isolated schema" do
    schema = TipTap.default_schema.dup
    schema.register_mark("spoiler", spoiler_mark)

    node = TipTap::Nodes::Text.new(
      "secret",
      marks: [{type: "spoiler"}, {type: "bold"}],
      schema: schema
    )

    expect(node.to_html).to eq('<strong><span class="spoiler">secret</span></strong>')
    expect(node.to_markdown).to eq("**||secret||**")
    expect(node.to_h[:marks]).to eq([{type: "spoiler"}, {type: "bold"}])

    # Default schema does not know spoiler — only bold applies
    default_node = TipTap::Nodes::Text.new(
      "secret",
      marks: [{type: "spoiler"}, {type: "bold"}]
    )
    expect(default_node.to_html).to eq("<strong>secret</strong>")
    expect(TipTap.default_schema.mark_registered?("spoiler")).to eq(false)
  end

  it "exposes Registry mark helpers as a façade" do
    expect(TipTap::Registry.mark_for("bold")).to eq(TipTap::Marks::Bold)
  end
end
