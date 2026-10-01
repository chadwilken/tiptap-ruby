# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Code < Mark
      self.type_name = "code"
      self.html_priority = 40
      self.markdown_priority = 0

      def self.exclusive_markdown?
        true
      end

      def wrap_html(value)
        content_tag(:code, value)
      end

      def wrap_markdown(value, context: nil)
        max_tick_sequence = value.scan(/`+/).map(&:length).max || 0
        wrapper = "`" * (max_tick_sequence + 1)
        "#{wrapper}#{value}#{wrapper}"
      end
    end
  end
end
