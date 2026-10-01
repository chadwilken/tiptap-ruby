# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Nodes::HorizontalRule do
  describe "to_html" do
    it "returns a hr tag" do
      node = TipTap::Nodes::HorizontalRule.new
      html = node.to_html

      expect(html).to eq("<hr>")
    end
  end

  describe "to_h" do
    it "returns a JSON object" do
      node = TipTap::Nodes::HorizontalRule.new
      expect(node.to_h).to eq({type: "horizontalRule"})
    end
  end

  describe "parent_builder" do
    it "adds horizontal_rule on Document" do
      document = TipTap::Document.new do |doc|
        doc.paragraph { |p| p.text("Above") }
        doc.horizontal_rule
        doc.paragraph { |p| p.text("Below") }
      end

      expect(document.content.map(&:class)).to eq([
        TipTap::Nodes::Paragraph,
        TipTap::Nodes::HorizontalRule,
        TipTap::Nodes::Paragraph
      ])
      expect(document.to_h).to eq({
        type: "doc",
        content: [
          {type: "paragraph", content: [{type: "text", text: "Above"}]},
          {type: "horizontalRule"},
          {type: "paragraph", content: [{type: "text", text: "Below"}]}
        ]
      })

      round_trip = TipTap::Document.from_json(document.to_h)
      expect(round_trip.to_h).to eq(document.to_h)
    end
  end
end
