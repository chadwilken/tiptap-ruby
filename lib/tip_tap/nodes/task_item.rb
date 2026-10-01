# frozen_string_literal: true

require "tip_tap/nodes/list_item"

module TipTap
  module Nodes
    class TaskItem < ListItem
      self.type_name = "taskItem"
      self.html_tag = :li
      self.html_class_name = proc { class_names("task-item", {checked: checked?}) }

      parent_builder on: "TipTap::Nodes::TaskList", as: :task_item, require_block: true, args: {checked: false}

      def checked?
        attrs["checked"]
      end

      def to_markdown(context = Markdown::Context.root)
        marker = checked? ? "- [x] " : "- [ ] "
        super(context, marker: marker)
      end
    end
  end
end
