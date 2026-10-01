# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class OrderedList < Node
      self.type_name = "orderedList"
      self.html_tag = :ol
      self.html_class_name = "ordered-list"

      parent_builder on: [
        TipTap::Document,
        "TipTap::Nodes::ListItem"
      ], as: :ordered_list, require_block: true

      def start
        attrs["start"]
      end

      def to_markdown(context = Markdown::Context.root)
        starting_index = start.to_i
        starting_index = 1 if starting_index <= 0

        content.each_with_index.map do |node, index|
          marker = "#{starting_index + index}. "
          node.to_markdown(context, marker: marker)
        end.join("\n")
      end
    end
  end
end
