# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class TextStyle < Mark
      self.type_name = "textStyle"
      self.html_priority = 100
      self.markdown_priority = 60

      def wrap_html(value)
        content_tag(:span, value, style: inline_style_content(attrs))
      end

      def wrap_markdown(value, context: nil)
        return value if attrs.empty?

        wrap_with_html_tag("span", value, {}, attrs)
      end
    end
  end
end
