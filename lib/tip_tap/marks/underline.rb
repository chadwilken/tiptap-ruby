# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Underline < Mark
      self.type_name = "underline"
      self.html_priority = 50
      self.markdown_priority = 40

      def wrap_html(value)
        content_tag(:u, value)
      end

      def wrap_markdown(value, context: nil)
        wrap_with_html_tag("u", value)
      end
    end
  end
end
