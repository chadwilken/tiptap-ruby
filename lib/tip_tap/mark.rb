# frozen_string_literal: true

require "action_view"
require "uri"
require "active_support/core_ext/hash"
require "active_support/core_ext/object/blank"

module TipTap
  # Base class for TipTap marks (bold, link, highlight, …).
  # Subclasses register on TipTap.default_schema via type_name=.
  class Mark
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::AssetTagHelper

    attr_accessor :output_buffer
    attr_reader :attrs

    def self.type_name=(name)
      @type_name = name
      TipTap.default_schema.register_mark(name, self)
    end

    def self.type_name
      @type_name
    end

    def self.html_priority=(value)
      @html_priority = value
    end

    def self.html_priority
      @html_priority || 100
    end

    def self.markdown_priority=(value)
      @markdown_priority = value
    end

    def self.markdown_priority
      @markdown_priority || 100
    end

    # When true, Text#to_markdown applies only this mark (no escaping / other marks).
    def self.exclusive_markdown?
      false
    end

    def self.from_hash(hash)
      hash = hash.deep_stringify_keys
      new(Hash(hash["attrs"]))
    end

    def initialize(attrs = {})
      @attrs = Hash(attrs).deep_stringify_keys
    end

    def type_name
      self.class.type_name
    end

    def to_h
      data = {type: type_name}
      data[:attrs] = attrs.deep_symbolize_keys if attrs.present?
      data
    end

    # Wrap already-rendered HTML (or plain text) with this mark's tags.
    def wrap_html(value)
      value
    end

    # Wrap markdown source with this mark's syntax / HTML fallbacks.
    def wrap_markdown(value, context: nil)
      value
    end

    protected

    def inline_style_content(styles)
      return nil if styles.nil? || styles.empty?

      styles.reduce("") { |acc, val| acc + "#{val[0]}:#{val[1]};" }
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

    def escape_double_quotes(value)
      value.to_s.gsub('"', "&quot;")
    end
  end
end
