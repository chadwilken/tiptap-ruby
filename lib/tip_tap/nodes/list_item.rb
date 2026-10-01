# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class ListItem < Node
      self.type_name = "listItem"
      self.html_tag = :li
      self.html_class_name = "list-item"

      parent_builder on: [
        "TipTap::Nodes::BulletList",
        "TipTap::Nodes::OrderedList"
      ], as: :list_item, require_block: true

      def to_markdown(context = Markdown::Context.root, marker: "- ")
        marker_length = marker.length
        first_prefix = context.indentation + marker
        rest_prefix = " " * (context.indent + marker_length)
        child_context = context.increase_indent(marker_length)

        segments = content.map do |node|
          if list_node?(node)
            {type: :list, text: node.to_markdown(child_context)}
          elsif paragraph_node?(node)
            {type: :inline, text: node.to_markdown(child_context)}
          else
            {type: :block, text: node.to_markdown(child_context)}
          end
        end

        first_segment = segments.shift || {type: :inline, text: ""}
        first_text = (first_segment[:type] == :list) ? "" : first_segment[:text]
        result = format_block(first_text, first_prefix, rest_prefix)

        segments.each do |segment|
          case segment[:type]
          when :list
            result << "\n" unless result.end_with?("\n")
            result << segment[:text]
          else
            result << "\n\n"
            result << format_block(segment[:text], rest_prefix, rest_prefix)
          end
        end

        result
      end

      private

      def paragraph_node?(node)
        node.is_a?(Paragraph)
      end

      def list_node?(node)
        node.is_a?(BulletList) || node.is_a?(OrderedList) || node.is_a?(TaskList)
      end

      def format_block(text, first_prefix, rest_prefix)
        lines = text.to_s.split("\n", -1)
        return first_prefix if lines.empty?

        formatted = "#{first_prefix}#{lines.first}"
        lines[1..]&.each do |line|
          formatted << "\n#{rest_prefix}#{line}"
        end
        formatted
      end
    end
  end
end
