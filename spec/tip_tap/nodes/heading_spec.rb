# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Nodes::Heading do
  before do
    allow(SecureRandom).to receive(:uuid).and_return("auto-uuid-999")
  end

  describe "to_html" do
    it "returns a tag corresponding to the level attribute with generated TOC ids when missing" do
      node = TipTap::Nodes::Heading.from_json({content: [], attrs: {level: 2}})
      html = node.to_html

      expect(html).to be_a(String)
      expect(html).to eq('<h2 id="auto-uuid-999" data-toc-id="auto-uuid-999"></h2>')
    end

    context "when the textAlign attribute is present" do
      it "returns a tag with the specified text alignment style" do
        node = TipTap::Nodes::Heading.from_json({content: [], attrs: {"textAlign" => "center", :level => 2}})
        html = node.to_html

        expect(html).to be_a(String)
        expect(html).to eq('<h2 style="text-align: center;" id="auto-uuid-999" data-toc-id="auto-uuid-999"></h2>')
      end
    end
  end

  describe "level" do
    it "returns the level attribute" do
      node = TipTap::Nodes::Heading.from_json({content: [], attrs: {level: 2}})
      expect(node.level).to eq(2)
    end
  end

  describe "table of contents ids" do
    it "generates id and data-toc-id when missing (Heading.new default)" do
      heading = TipTap::Nodes::Heading.new(level: 1)

      expect(heading.attrs["id"]).to eq("auto-uuid-999")
      expect(heading.attrs["data-toc-id"]).to eq("auto-uuid-999")
    end

    it "preserves id and data-toc-id from attrs / JSON" do
      heading = TipTap::Nodes::Heading.from_json({
        content: [{type: "text", text: "Hi"}],
        attrs: {level: 2, id: "keep-me", "data-toc-id": "keep-me-toc"}
      })

      expect(heading.attrs["id"]).to eq("keep-me")
      expect(heading.attrs["data-toc-id"]).to eq("keep-me-toc")
      expect(SecureRandom).not_to have_received(:uuid)

      expect(heading.to_h).to eq({
        type: "heading",
        attrs: {level: 2, id: "keep-me", "data-toc-id": "keep-me-toc"},
        content: [{type: "text", text: "Hi"}]
      })

      round_trip = TipTap::Nodes::Heading.from_json(heading.to_h)
      expect(round_trip.to_h).to eq(heading.to_h)
    end

    it "fills only the missing TOC attr from the other when generating" do
      heading = TipTap::Nodes::Heading.new(level: 1, id: "only-id")

      expect(heading.attrs["id"]).to eq("only-id")
      expect(heading.attrs["data-toc-id"]).to eq("only-id")
      expect(SecureRandom).not_to have_received(:uuid)
    end

    it "skips generation when generate_toc_ids: false" do
      heading = TipTap::Nodes::Heading.new(level: 1, generate_toc_ids: false)

      expect(heading.attrs["id"]).to be_nil
      expect(heading.attrs["data-toc-id"]).to be_nil
      expect(SecureRandom).not_to have_received(:uuid)
    end

    it "honors generate_toc_ids: false on Document.from_json" do
      document = TipTap::Document.from_json({
        type: "doc",
        content: [
          {type: "heading", attrs: {level: 1}, content: [{type: "text", text: "A"}]}
        ]
      }, generate_toc_ids: false)

      heading = document.content.first
      expect(heading.attrs["id"]).to be_nil
      expect(heading.attrs["data-toc-id"]).to be_nil
      expect(heading.to_html).to eq("<h1>A</h1>")
    end

    it "honors generate_toc_ids: true on from_json when ids are missing" do
      heading = TipTap::Nodes::Heading.from_json(
        {content: [], attrs: {level: 1}},
        generate_toc_ids: true
      )

      expect(heading.attrs["id"]).to eq("auto-uuid-999")
      expect(heading.attrs["data-toc-id"]).to eq("auto-uuid-999")
    end
  end

  describe "text" do
    it "adds a text node to the node" do
      heading = TipTap::Nodes::Heading.new(level: 1)
      heading.text("Hello World!")

      expect(heading.content.first).to be_a(TipTap::Nodes::Text)
    end
  end

  describe "to_h" do
    it "returns a JSON object" do
      node = TipTap::Nodes::Heading.new(level: 1)
      json = node.to_h

      expect(json).to eq({type: "heading", attrs: {level: 1, id: "auto-uuid-999", "data-toc-id": "auto-uuid-999"}, content: []})
    end
  end
end
