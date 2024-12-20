# frozen_string_literal: true

require "tip_tap"

RSpec.describe TipTap::Nodes::Image do
  describe "to_html" do
    it "returns an image tag" do
      node = TipTap::Nodes::Image.new(src: "https://img.companycam.com/abcd1234.jpeg")
      html = node.to_html

      expect(html).to be_a(String)
      expect(html).to eq('<img src="https://img.companycam.com/abcd1234.jpeg" />')
    end

    it "optionally returns additional attributes" do
      node = TipTap::Nodes::Image.new(src: "https://img.companycam.com/abcd1234.jpeg", alt: "Alt text example")
      html = node.to_html

      expect(html).to be_a(String)
      expect(html).to eq('<img alt="Alt text example" src="https://img.companycam.com/abcd1234.jpeg" />')
    end
  end

  describe "src" do
    it "returns the src attribute" do
      node = TipTap::Nodes::Image.new(src: "https://img.companycam.com/abcd1234.jpeg")
      expect(node.src).to eq("https://img.companycam.com/abcd1234.jpeg")
    end
  end

  describe "to_h" do
    it "returns a JSON object" do
      node = TipTap::Nodes::Image.new(src: "https://img.companycam.com/abcd1234.jpeg")
      json = node.to_h

      expect(json).to eq({type: "image", attrs: {src: "https://img.companycam.com/abcd1234.jpeg"}})
    end
  end
end
