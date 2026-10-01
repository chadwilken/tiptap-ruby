# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Image < Node
      self.type_name = "image"

      parent_builder on: TipTap::Document, as: :image, args: [:src]

      def include_empty_content_in_json?
        false
      end

      def to_html
        image_tag(src, alt: alt)
      end

      def to_markdown(context = Markdown::Context.root)
        return "" if src.blank?

        alt_text = alt.to_s
        escaped_alt = alt_text.gsub("[", "\\[").gsub("]", "\\]")
        escaped_src = src.to_s.gsub("(", "\\(").gsub(")", "\\)")
        "![#{escaped_alt}](#{escaped_src})"
      end

      def alt
        attrs["alt"]
      end

      def src
        attrs["src"]
      end
    end
  end
end
