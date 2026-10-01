# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::ParentBuildable do
  describe "built-in builders via parent_builder" do
    it "installs Document builders from child declarations" do
      document = TipTap::Document.new do |doc|
        doc.paragraph { |p| p.text("Hi") }
        doc.heading(level: 2) { |h| h.text("Title") }
        doc.image(src: "https://example.com/a.png")
      end

      expect(document.content.map(&:class)).to eq([
        TipTap::Nodes::Paragraph,
        TipTap::Nodes::Heading,
        TipTap::Nodes::Image
      ])
      expect(document.content[1].level).to eq(2)
      expect(document.content[2].src).to eq("https://example.com/a.png")
    end

    it "preserves Document#paragraph without a required block" do
      document = TipTap::Document.new.tap(&:paragraph)
      expect(document.content.first).to be_a(TipTap::Nodes::Paragraph)
      expect(document.blank?).to eq(true)
    end

    it "requires a block for ListItem#paragraph" do
      item = TipTap::Nodes::ListItem.new
      expect { item.paragraph }.to raise_error(ArgumentError, "Block required")
    end

    it "requires src for Document#image" do
      document = TipTap::Document.new
      expect { document.image }.to raise_error(ArgumentError, /missing keyword/)
    end
  end

  describe "custom node with parent_builder" do
    let(:callout_class) do
      Class.new(TipTap::Node) do
        self.html_tag = :aside
        self.html_class_name = "callout"

        def self.name
          "TipTap::Nodes::Callout"
        end

        parent_builder on: TipTap::Document, as: :callout, require_block: true

        def self.type_name
          "callout"
        end
      end
    end

    it "adds a builder on Document without monkey-patching Document's source" do
      TipTap.default_schema.register("callout", callout_class)
      # parent_builder already ran at class definition; register also reinstalls

      document = TipTap::Document.new do |doc|
        doc.callout { |node| node }
      end

      expect(document.content.first).to be_a(callout_class)
      expect { TipTap::Document.new.callout }.to raise_error(ArgumentError, "Block required")
    end
  end
end
