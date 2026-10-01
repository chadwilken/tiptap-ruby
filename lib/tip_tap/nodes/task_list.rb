# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class TaskList < Node
      self.type_name = "taskList"
      self.html_tag = :ul
      self.html_class_name = "task-list"

      parent_builder on: [
        TipTap::Document,
        "TipTap::Nodes::ListItem"
      ], as: :task_list, require_block: true

      def to_markdown(context = Markdown::Context.root)
        content.map { |node| node.to_markdown(context) }.join("\n")
      end
    end
  end
end
