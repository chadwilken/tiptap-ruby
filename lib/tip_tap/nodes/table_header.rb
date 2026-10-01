# frozen_string_literal: true

require "tip_tap/nodes/table_cell"

module TipTap
  module Nodes
    class TableHeader < TableCell
      self.type_name = "tableHeader"
      self.html_tag = :th

      parent_builder on: "TipTap::Nodes::TableRow", as: :table_header, require_block: true
    end
  end
end
