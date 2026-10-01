# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Italic < Mark
      self.type_name = "italic"
      self.html_priority = 60
      self.markdown_priority = 20

      def wrap_html(value)
        content_tag(:em, value)
      end

      def wrap_markdown(value, context: nil)
        "_#{value}_"
      end
    end
  end
end
