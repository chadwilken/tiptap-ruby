# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Superscript < Mark
      self.type_name = "superscript"
      self.html_priority = 10
      self.markdown_priority = 70

      def wrap_html(value)
        content_tag(:sup, value)
      end

      def wrap_markdown(value, context: nil)
        wrap_with_html_tag("sup", value)
      end
    end
  end
end
