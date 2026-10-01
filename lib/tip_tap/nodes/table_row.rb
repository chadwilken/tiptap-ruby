# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class TableRow < Node
      self.type_name = "tableRow"
      self.html_tag = :tr

      parent_builder on: "TipTap::Nodes::Table", as: :table_row, require_block: true

      def to_markdown(context = Markdown::Context.root)
        row_data = to_markdown_row(context)
        "| #{row_data[:cells].join(" | ")} |"
      end

      def to_markdown_row(context)
        {
          cells: content.map { |node| node.to_markdown(context) },
          is_header: content.all? { |node| node.is_a?(TableHeader) }
        }
      end
    end
  end
end
