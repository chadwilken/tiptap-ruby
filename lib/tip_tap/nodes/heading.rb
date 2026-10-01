# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Heading < Node
      self.type_name = "heading"
      self.html_tag = proc { "h#{level}" }

      parent_builder on: TipTap::Document, as: :heading, require_block: true, args: {level: 1}

      def initialize(content = [], **attributes)
        super(content, **attributes)
        uuid = SecureRandom.uuid
        @attrs["id"] = uuid
        @attrs["data-toc-id"] = uuid
      end

      def text(text, marks: [])
        add_content(Text.new(text, marks: marks))
      end

      def level
        attrs["level"]
      end

      def html_attributes
        # doc-toc-id comes from TipTap and Ruby symbols do not support -
        # so we use string keys here instead.
        {
          "style" => inline_styles,
          "class" => html_class_name,
          "id" => attrs["id"],
          "data-toc-id" => attrs["data-toc-id"]
        }.reject { |key, value| value.blank? }
      end

      def to_markdown(context = Markdown::Context.root)
        heading_level = [level.to_i, 1].max
        prefix = "#" * heading_level
        body = content.map { |node| node.to_markdown(context) }.join.strip
        body.empty? ? prefix : "#{prefix} #{body}"
      end
    end
  end
end
