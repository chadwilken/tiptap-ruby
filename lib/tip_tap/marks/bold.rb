# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Bold < Mark
      self.type_name = "bold"
      self.html_priority = 70
      self.markdown_priority = 10

      def wrap_html(value)
        content_tag(:strong, value)
      end

      def wrap_markdown(value, context: nil)
        "**#{value}**"
      end
    end
  end
end
