# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Nodes::HardBreak do
  describe "to_html" do
    it "returns a br tag" do
      node = TipTap::Nodes::HardBreak.new
      html = node.to_html

      expect(html).to eq("<br>")
    end
  end

  describe "to_h" do
    it "returns a JSON object" do
      node = TipTap::Nodes::HardBreak.new
      expect(node.to_h).to eq({type: "hardBreak"})
    end
  end

  describe "parent_builder" do
    it "adds hard_break on Paragraph and Heading" do
      paragraph = TipTap::Nodes::Paragraph.new do |p|
        p.text("Hello")
        p.hard_break
        p.text("World")
      end

      expect(paragraph.content.map(&:class)).to eq([
        TipTap::Nodes::Text,
        TipTap::Nodes::HardBreak,
        TipTap::Nodes::Text
      ])
      expect(paragraph.to_h).to eq({
        type: "paragraph",
        content: [
          {type: "text", text: "Hello"},
          {type: "hardBreak"},
          {type: "text", text: "World"}
        ]
      })

      round_trip = TipTap::Nodes::Paragraph.from_json(paragraph.to_h)
      expect(round_trip.to_h).to eq(paragraph.to_h)

      heading = TipTap::Nodes::Heading.new(level: 1) do |h|
        h.text("Title")
        h.hard_break
        h.text("Line 2")
      end

      expect(heading.content.map(&:class)).to eq([
        TipTap::Nodes::Text,
        TipTap::Nodes::HardBreak,
        TipTap::Nodes::Text
      ])
      expect(heading.to_h[:content]).to eq([
        {type: "text", text: "Title"},
        {type: "hardBreak"},
        {type: "text", text: "Line 2"}
      ])
    end
  end
end
