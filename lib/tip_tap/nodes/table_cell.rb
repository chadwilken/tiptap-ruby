# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class TableCell < Node
      self.type_name = "tableCell"
      self.html_tag = :td

      parent_builder on: "TipTap::Nodes::TableRow", as: :table_cell, require_block: true

      def to_markdown(context = Markdown::Context.root)
        values = content.map { |node| node.to_markdown(context) }.reject(&:blank?)
        joined = values.join("<br>")
        joined.gsub("\n\n", "<br><br>").gsub("\n", "<br>")
      end
    end
  end
end
