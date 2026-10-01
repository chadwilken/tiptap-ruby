# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Text < Node
      # Allow the text to be set and accessed directly
      attr_accessor :text
      attr_reader :marks, :schema

      self.type_name = "text"

      def initialize(content, **attributes)
        @text = content
        @schema = attributes[:schema] || TipTap.default_schema
        @marks = Array(attributes[:marks]).map(&:deep_stringify_keys)
        yield self if block_given?
      end

      def self.from_json(json, schema: TipTap.default_schema, unknown_node: nil, generate_toc_ids: nil)
        json.deep_stringify_keys!

        new(json["text"], marks: Array(json["marks"]), schema: schema)
      end

      def to_h
        data = {type: type_name, text: text || ""}
        data[:marks] = marks.map(&:deep_symbolize_keys) unless marks.empty?
        data
      end

      def to_html
        apply_marks(text, :html)
      end

      def to_plain_text(separator: " ")
        text
      end

      def to_markdown(context = Markdown::Context.root)
        value = text.to_s
        return "" if value.empty?

        return value if context.within_code_block?

        exclusive = mark_objects.find { |mark| mark.class.exclusive_markdown? }
        return exclusive.wrap_markdown(value, context: context) if exclusive

        value = escape_markdown(value)
        apply_marks(value, :markdown, context: context)
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

      def mark_objects
        marks.filter_map do |mark_hash|
          type = mark_hash["type"]
          next unless schema.mark_registered?(type)

          schema.mark_for(type).from_hash(mark_hash)
        end
      end

      def apply_marks(value, format, context: nil)
        sorted = mark_objects.sort_by do |mark|
          (format == :html) ? mark.class.html_priority : mark.class.markdown_priority
        end

        sorted.reduce(value) do |current, mark|
          if format == :html
            mark.wrap_html(current)
          else
            mark.wrap_markdown(current, context: context)
          end
        end
      end

      def escape_markdown(value)
        value.gsub(/([\\`*_{}\[\]()#+!><~-])/) { |char| "\\#{char}" }
      end
    end
  end
end
