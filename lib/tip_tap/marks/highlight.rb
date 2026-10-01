# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Highlight < Mark
      self.type_name = "highlight"
      self.html_priority = 30
      self.markdown_priority = 50

      def wrap_html(value)
        data = {}
        styles = {}
        if color
          data[:color] = color
          styles["background-color"] = color
          styles[:color] = "inherit"
        end
        content_tag(:mark, value, data: data, style: inline_style_content(styles))
      end

      def wrap_markdown(value, context: nil)
        attributes = {}
        styles = {}
        if color
          attributes["data-color"] = color
          styles["background-color"] = color
          styles["color"] = "inherit"
        end
        wrap_with_html_tag("mark", value, attributes, styles)
      end

      def color
        attrs["color"]
      end
    end
  end
end
