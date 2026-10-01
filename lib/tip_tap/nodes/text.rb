# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Text < Node
      # Allow the text to be set and accessed directly
      attr_accessor :text
      attr_reader :marks

      self.type_name = "text"

      def initialize(content, **attributes)
        @text = content
        @marks = Array(attributes[:marks]).map(&:deep_stringify_keys)
        yield self if block_given?
      end

      def self.from_json(json, schema: TipTap.default_schema)
        json.deep_stringify_keys!

        new(json["text"], marks: Array(json["marks"]))
      end

      def to_h
        data = {type: type_name, text: text || ""}
        data[:marks] = marks.map(&:deep_symbolize_keys) unless marks.empty?
        data
      end

      def to_html
        value = text
        value = content_tag(:sup, value) if superscript?
        value = content_tag(:sub, value) if subscript?
        value = highlight_tag(value) if highlight?
        value = content_tag(:code, value) if code?
        value = content_tag(:u, value) if underline?
        value = content_tag(:em, value) if italic?
        value = content_tag(:strong, value) if bold?
        value = content_tag(:s, value) if strike?
        value = content_tag(:a, value, href: link_href, target: link_target) if link?
        value = content_tag(:span, value, style: inline_style_content(text_styles)) if text_style?
        value
      end

      def to_plain_text(separator: " ")
        text
      end

      def to_markdown(context = Markdown::Context.root)
        value = text.to_s
        return "" if value.empty?

        return value if context.within_code_block?

        return wrap_with_backticks(value) if code?

        value = escape_markdown(value)
        value = apply_bold(value) if bold?
        value = apply_italic(value) if italic?
        value = apply_strike(value) if strike?
        value = wrap_with_html_tag("u", value) if underline?
        value = apply_highlight(value) if highlight?
        value = apply_text_style(value) if text_style?
        value = wrap_with_html_tag("sup", value) if superscript?
        value = wrap_with_html_tag("sub", value) if subscript?
        value = wrap_with_link(value) if link?
        value
      end

      def italic?
        has_mark_with_type?("italic")
      end

      def bold?
        has_mark_with_type?("bold")
      end

      def underline?
        has_mark_with_type?("underline")
      end

      def link?
        has_mark_with_type?("link")
      end

      def strike?
        has_mark_with_type?("strike")
      end

      def code?
        has_mark_with_type?("code")
      end

      def superscript?
        has_mark_with_type?("superscript")
      end

      def subscript?
        has_mark_with_type?("subscript")
      end

      def highlight?
        has_mark_with_type?("highlight")
      end

      def text_style?
        has_mark_with_type?("textStyle")
      end

      private

      def has_mark_with_type?(type)
        marks.any? { |mark| mark["type"] == type }
      end

      def link_href
        marks.find { |mark| mark["type"] == "link" }&.dig("attrs", "href")
      end

      def link_target
        marks.find { |mark| mark["type"] == "link" }&.dig("attrs", "target")
      end

      def text_styles
        marks.find { |mark| mark["type"] == "textStyle" }&.dig("attrs")
      end

      def highlight_color
        marks.find { |mark| mark["type"] == "highlight" }&.dig("attrs", "color")
      end

      def inline_style_content(styles)
        return nil if styles.empty?
        styles.reduce("") { |acc, val| acc + "#{val[0]}:#{val[1]};" }
      end

      def highlight_tag(value)
        data = {}
        styles = {}
        if highlight_color
          data[:color] = highlight_color
          styles["background-color"] = highlight_color
          styles[:color] = "inherit"
        end
        content_tag(:mark, text, data: data, style: inline_style_content(styles))
      end

      def escape_markdown(value)
        value.gsub(/([\\`*_{}\[\]()#+!><~-])/) { |char| "\\#{char}" }
      end

      def wrap_with_backticks(value)
        max_tick_sequence = value.scan(/`+/).map(&:length).max || 0
        wrapper = "`" * (max_tick_sequence + 1)
        "#{wrapper}#{value}#{wrapper}"
      end

      def apply_bold(value)
        "**#{value}**"
      end

      def apply_italic(value)
        "_#{value}_"
      end

      def apply_strike(value)
        "~~#{value}~~"
      end

      def apply_highlight(value)
        attributes = {}
        styles = {}
        if highlight_color
          attributes["data-color"] = highlight_color
          styles["background-color"] = highlight_color
          styles["color"] = "inherit"
        end
        wrap_with_html_tag("mark", value, attributes, styles)
      end

      def apply_text_style(value)
        styles = text_styles || {}
        return value if styles.empty?

        wrap_with_html_tag("span", value, {}, styles)
      end

      def wrap_with_link(value)
        href = link_href.to_s
        return value if href.blank?

        destination = escape_link_destination(href)
        title = link_title
        title_part = title.present? ? " \"#{escape_double_quotes(title)}\"" : ""
        "[#{value}](#{destination}#{title_part})"
      end

      def wrap_with_html_tag(tag, value, attributes = {}, styles = {})
        attr_segments = []
        attributes.each do |key, attr_value|
          next if attr_value.blank?
          attr_segments << "#{key}=\"#{escape_double_quotes(attr_value)}\""
        end
        style_segment = inline_style_content(styles)
        attr_segments << "style=\"#{escape_double_quotes(style_segment)}\"" if style_segment.present?
        attributes_string = attr_segments.empty? ? "" : " #{attr_segments.join(" ")}"
        "<#{tag}#{attributes_string}>#{value}</#{tag}>"
      end

      def escape_link_destination(href)
        escaped = href.gsub("(", "\\(").gsub(")", "\\)")
        escaped.gsub(/[\s]/) do |char|
          (char == " ") ? "%20" : char
        end
      end

      def escape_double_quotes(value)
        value.to_s.gsub('"', "&quot;")
      end

      def link_title
        marks.find { |mark| mark["type"] == "link" }&.dig("attrs", "title")
      end
    end
  end
end
