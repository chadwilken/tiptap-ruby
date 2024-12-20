# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Image < Node
      self.type_name = "image"

      def include_empty_content_in_json?
        false
      end

      def to_html
        image_tag(src, attrs.except("src"))
      end

      def src
        attrs["src"]
      end
    end
  end
end
