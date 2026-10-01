# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class HorizontalRule < Node
      self.type_name = "horizontalRule"

      parent_builder on: TipTap::Document, as: :horizontal_rule

      def include_empty_content_in_json?
        false
      end

      def to_html
        tag.hr
      end

      def to_markdown(context = Markdown::Context.root)
        "---"
      end
    end
  end
end
