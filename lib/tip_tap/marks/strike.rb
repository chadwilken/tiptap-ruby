# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Strike < Mark
      self.type_name = "strike"
      self.html_priority = 80
      self.markdown_priority = 30

      def wrap_html(value)
        content_tag(:s, value)
      end

      def wrap_markdown(value, context: nil)
        "~~#{value}~~"
      end
    end
  end
end
