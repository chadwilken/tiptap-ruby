# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Schema do
  describe "#register / #node_for" do
    it "registers and looks up a custom node" do
      schema = TipTap::Schema.new
      schema.register("myCustomNode", String)

      expect(schema.node_for("myCustomNode")).to eq(String)
      expect(schema.registered?("myCustomNode")).to eq(true)
    end

    it "raises MissingNodeError for unknown types" do
      schema = TipTap::Schema.new

      expect { schema.node_for("unknown") }.to raise_error(TipTap::Schema::MissingNodeError)
    end
  end

  describe "default schema" do
    it "includes built-in node types" do
      schema = TipTap.default_schema

      expect(schema.node_for("doc")).to eq(TipTap::Document)
      expect(schema.node_for("paragraph")).to eq(TipTap::Nodes::Paragraph)
      expect(schema.node_for("text")).to eq(TipTap::Nodes::Text)
      expect(schema.node_for("heading")).to eq(TipTap::Nodes::Heading)
    end

    it "is used by TipTap.node_for" do
      expect(TipTap.node_for("paragraph")).to eq(TipTap::Nodes::Paragraph)
    end
  end

  describe "parsing with a custom schema" do
    let(:custom_node_class) do
      Class.new(TipTap::Node) do
        self.html_tag = :div

        def self.type_name
          "customBlock"
        end
      end
    end

    it "parses JSON using the given schema without registering on the default schema" do
      schema = TipTap.default_schema.dup
      schema.register("customBlock", custom_node_class)

      json = {
        type: "doc",
        content: [
          {
            type: "customBlock",
            content: [
              {type: "text", text: "Hello custom"}
            ]
          }
        ]
      }

      document = TipTap::Document.from_json(json, schema: schema)

      expect(document.content.first).to be_a(custom_node_class)
      expect(document.content.first.content.first).to be_a(TipTap::Nodes::Text)
      expect(document.to_plain_text).to eq("Hello custom")

      expect {
        TipTap::Document.from_json(json)
      }.to raise_error(TipTap::Schema::MissingNodeError)

      expect(TipTap.default_schema.registered?("customBlock")).to eq(false)
    end
  end

  describe "#use" do
    it "merges nodes from another schema" do
      base = TipTap::Schema.new
      base.register("paragraph", TipTap::Nodes::Paragraph)

      extra = TipTap::Schema.new
      extra.register("text", TipTap::Nodes::Text)

      base.use(extra)

      expect(base.node_for("paragraph")).to eq(TipTap::Nodes::Paragraph)
      expect(base.node_for("text")).to eq(TipTap::Nodes::Text)
    end

    it "accepts an extension that responds to #register" do
      schema = TipTap::Schema.new
      extension = Object.new
      def extension.register(schema)
        schema.register("text", TipTap::Nodes::Text)
      end

      schema.use(extension)

      expect(schema.node_for("text")).to eq(TipTap::Nodes::Text)
    end
  end

  describe "#dup" do
    it "copies registrations without sharing the hash" do
      original = TipTap.default_schema.dup
      copy = original.dup
      copy.register("onlyOnCopy", String)

      expect(copy.registered?("onlyOnCopy")).to eq(true)
      expect(original.registered?("onlyOnCopy")).to eq(false)
    end
  end
end
