# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Subscript < Mark
      self.type_name = "subscript"
      self.html_priority = 20
      self.markdown_priority = 80

      def wrap_html(value)
        content_tag(:sub, value)
      end

      def wrap_markdown(value, context: nil)
        wrap_with_html_tag("sub", value)
      end
    end
  end
end
