# frozen_string_literal: true

require_relative "tip_tap/version"
require "tip_tap/schema"
require "tip_tap/registry"
require "tip_tap/mark"

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

  def self.mark_for(name)
    default_schema.mark_for(name)
  end

  # Re-run parent_builder installation after all node classes are loaded
  # (declarations may reference parents that were not defined yet).
  def self.install_parent_builders!
    default_schema.nodes.values.uniq.each do |klass|
      klass.install_parent_builders! if klass.respond_to?(:install_parent_builders!)
    end
  end
end

# Marks register themselves onto TipTap.default_schema via type_name=.
require "tip_tap/marks/bold"
require "tip_tap/marks/italic"
require "tip_tap/marks/underline"
require "tip_tap/marks/strike"
require "tip_tap/marks/code"
require "tip_tap/marks/link"
require "tip_tap/marks/text_style"
require "tip_tap/marks/superscript"
require "tip_tap/marks/subscript"
require "tip_tap/marks/highlight"

# Nodes register themselves and declare parent_builder onto parents.
# Order is mostly free-form; install_parent_builders! finalizes forward refs.
require "tip_tap/document"
require "tip_tap/nodes/text"
require "tip_tap/nodes/unknown"
require "tip_tap/nodes/hard_break"
require "tip_tap/nodes/horizontal_rule"
require "tip_tap/nodes/paragraph"
require "tip_tap/nodes/heading"
require "tip_tap/nodes/image"
require "tip_tap/nodes/blockquote"
require "tip_tap/nodes/codeblock"
require "tip_tap/nodes/bullet_list"
require "tip_tap/nodes/ordered_list"
require "tip_tap/nodes/task_list"
require "tip_tap/nodes/list_item"
require "tip_tap/nodes/task_item"
require "tip_tap/nodes/table"
require "tip_tap/nodes/table_row"
require "tip_tap/nodes/table_cell"
require "tip_tap/nodes/table_header"

TipTap.install_parent_builders!
