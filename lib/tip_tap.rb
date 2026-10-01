# frozen_string_literal: true

require_relative "tip_tap/version"
require "tip_tap/schema"
require "tip_tap/registry"

module TipTap
  class Error < StandardError; end

  def self.default_schema
    @default_schema ||= Schema.new
  end

  def self.default_schema=(schema)
    @default_schema = schema
  end

  def self.node_for(name)
    default_schema.node_for(name)
  end
end

# Nodes register themselves onto TipTap.default_schema via type_name=,
# so default_schema must exist before these requires.
require "tip_tap/document"
require "tip_tap/nodes/bullet_list"
require "tip_tap/nodes/hard_break"
require "tip_tap/nodes/heading"
require "tip_tap/nodes/horizontal_rule"
require "tip_tap/nodes/list_item"
require "tip_tap/nodes/ordered_list"
require "tip_tap/nodes/paragraph"
require "tip_tap/nodes/task_item"
require "tip_tap/nodes/task_list"
require "tip_tap/nodes/text"
require "tip_tap/nodes/image"
require "tip_tap/nodes/blockquote"
require "tip_tap/nodes/codeblock"
require "tip_tap/nodes/table"
require "tip_tap/nodes/table_row"
require "tip_tap/nodes/table_cell"
require "tip_tap/nodes/table_header"
