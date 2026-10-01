# frozen_string_literal: true

require "tip_tap/mark"

module TipTap
  module Marks
    class Link < Mark
      self.type_name = "link"
      self.html_priority = 90
      self.markdown_priority = 90

      def wrap_html(value)
        content_tag(:a, value, href: href, target: target)
      end

      def wrap_markdown(value, context: nil)
        return value if href.blank?

        destination = escape_link_destination(href)
        title_part = title.present? ? " \"#{escape_double_quotes(title)}\"" : ""
        "[#{value}](#{destination}#{title_part})"
      end

      def href
        attrs["href"]
      end

      def target
        attrs["target"]
      end

      def title
        attrs["title"]
      end

      private

      def escape_link_destination(url)
        escaped = url.to_s.gsub("(", "\\(").gsub(")", "\\)")
        escaped.gsub(/[\s]/) do |char|
          (char == " ") ? "%20" : char
        end
      end
    end
  end
end
