# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Nodes::Unknown do
  let(:unknown_json) do
    {
      type: "doc",
      content: [
        {
          type: "paragraph",
          content: [{type: "text", text: "Known"}]
        },
        {
          type: "customWidget",
          attrs: {widget_id: 42},
          content: [
            {
              type: "paragraph",
              content: [{type: "text", text: "Inside unknown"}]
            }
          ]
        }
      ]
    }
  end

  describe "default :raise policy" do
    it "raises MissingNodeError for unregistered types" do
      expect {
        TipTap::Document.from_json(unknown_json)
      }.to raise_error(TipTap::Schema::MissingNodeError, /customWidget/)
    end

    it "keeps Registry::MissingNodeError as an alias" do
      expect {
        TipTap::Document.from_json(unknown_json)
      }.to raise_error(TipTap::Registry::MissingNodeError)
    end
  end

  describe "schema.unknown_node = :passthrough" do
    let(:schema) do
      TipTap.default_schema.dup.tap { |s| s.unknown_node = :passthrough }
    end

    it "preserves unknown nodes for to_h round-trip" do
      document = TipTap::Document.from_json(unknown_json, schema: schema)

      expect(document.content.size).to eq(2)
      expect(document.content.first).to be_a(TipTap::Nodes::Paragraph)
      unknown = document.content.last
      expect(unknown).to be_a(TipTap::Nodes::Unknown)
      expect(unknown.original_type).to eq("customWidget")
      expect(unknown.attrs["widgetId"]).to eq(42)
      expect(unknown.content.first).to be_a(TipTap::Nodes::Paragraph)

      expect(document.to_h).to eq({
        type: "doc",
        content: [
          {
            type: "paragraph",
            content: [{type: "text", text: "Known"}]
          },
          {
            type: "customWidget",
            content: [
              {
                type: "paragraph",
                content: [{type: "text", text: "Inside unknown"}]
              }
            ],
            attrs: {widgetId: 42}
          }
        ]
      })
    end

    it "renders HTML/markdown/plain from children only" do
      document = TipTap::Document.from_json(unknown_json, schema: schema)
      unknown = document.content.last

      expect(unknown.to_html).to eq("<p>Inside unknown</p>")
      expect(unknown.to_markdown).to eq("Inside unknown")
      expect(unknown.to_plain_text).to eq("Inside unknown")
      expect(document.to_plain_text).to include("Known", "Inside unknown")
    end
  end

  describe "from_json(unknown_node: :passthrough)" do
    it "opts in without mutating the schema" do
      schema = TipTap.default_schema.dup
      expect(schema.unknown_node).to eq(:raise)

      document = TipTap::Document.from_json(unknown_json, schema: schema, unknown_node: :passthrough)

      expect(document.content.last).to be_a(TipTap::Nodes::Unknown)
      expect(schema.unknown_node).to eq(:raise)

      expect {
        TipTap::Document.from_json(unknown_json, schema: schema)
      }.to raise_error(TipTap::Schema::MissingNodeError)
    end
  end

  describe "nested unknown nodes" do
    it "passthroughs unknown parents and children with the same policy" do
      json = {
        type: "doc",
        content: [
          {
            type: "outerUnknown",
            content: [
              {
                type: "innerUnknown",
                attrs: {flag: true},
                content: [
                  {type: "text", text: "Deep"}
                ]
              },
              {
                type: "paragraph",
                content: [{type: "text", text: "Sibling"}]
              }
            ]
          }
        ]
      }

      document = TipTap::Document.from_json(json, unknown_node: :passthrough)
      outer = document.content.first
      expect(outer).to be_a(TipTap::Nodes::Unknown)
      expect(outer.original_type).to eq("outerUnknown")

      inner = outer.content.first
      expect(inner).to be_a(TipTap::Nodes::Unknown)
      expect(inner.original_type).to eq("innerUnknown")
      expect(inner.content.first).to be_a(TipTap::Nodes::Text)
      expect(outer.content.last).to be_a(TipTap::Nodes::Paragraph)

      expect(document.to_h[:content].first[:type]).to eq("outerUnknown")
      expect(document.to_h[:content].first[:content].first[:type]).to eq("innerUnknown")
      expect(document.to_html).to eq('<div class="tiptap-document">Deep<p>Sibling</p></div>')
    end
  end

  describe "Schema#unknown_node=" do
    it "rejects invalid policies" do
      schema = TipTap::Schema.new
      expect { schema.unknown_node = :skip }.to raise_error(ArgumentError, /passthrough/)
    end

    it "is copied by dup" do
      schema = TipTap.default_schema.dup
      schema.unknown_node = :passthrough
      expect(schema.dup.unknown_node).to eq(:passthrough)
    end
  end
end
