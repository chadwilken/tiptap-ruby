# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Table < Node
      self.type_name = "table"
      self.html_tag = :table

      parent_builder on: TipTap::Document, as: :table, require_block: true

      def to_markdown(context = Markdown::Context.root)
        rows_data = content.map { |row| row.to_markdown_row(context) }
        return "" if rows_data.empty?

        column_count = rows_data.map { |row| row[:cells].size }.max || 0
        return "" if column_count.zero?

        header_index = rows_data.index { |row| row[:is_header] }
        header_cells = if header_index
          rows_data.delete_at(header_index)[:cells]
        else
          Array.new(column_count, "")
        end

        header_cells = pad_cells(header_cells, column_count)
        separator_cells = Array.new(column_count, "---")
        body_rows = rows_data.map { |row| pad_cells(row[:cells], column_count) }

        lines = []
        lines << format_row(header_cells)
        lines << format_row(separator_cells)
        body_rows.each { |cells| lines << format_row(cells) }
        lines.join("\n")
      end

      private

      def pad_cells(cells, desired_size)
        Array.new(desired_size) { |index| cells[index] || "" }
      end

      def format_row(cells)
        "| #{cells.join(" | ")} |"
      end
    end
  end
end
