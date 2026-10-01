# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class BulletList < Node
      self.type_name = "bulletList"
      self.html_tag = :ul
      self.html_class_name = "bullet-list"

      parent_builder on: [
        TipTap::Document,
        "TipTap::Nodes::ListItem"
      ], as: :bullet_list, require_block: true

      def to_markdown(context = Markdown::Context.root)
        content.map { |node| node.to_markdown(context, marker: "- ") }.join("\n")
      end
    end
  end
end
