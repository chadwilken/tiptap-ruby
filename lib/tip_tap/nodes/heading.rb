# frozen_string_literal: true

require "securerandom"
require "tip_tap/node"

module TipTap
  module Nodes
    class Heading < Node
      self.type_name = "heading"
      self.html_tag = proc { "h#{level}" }

      parent_builder on: TipTap::Document, as: :heading, require_block: true, args: {level: 1}

      # @param generate_toc_ids [Boolean] when true (default), set id / data-toc-id
      #   only if missing. Existing values from JSON/attrs are never overwritten.
      def initialize(content = [], **attributes)
        generate_toc_ids = true
        if attributes.key?(:generate_toc_ids)
          generate_toc_ids = attributes.delete(:generate_toc_ids)
        elsif attributes.key?("generate_toc_ids")
          generate_toc_ids = attributes.delete("generate_toc_ids")
        end

        super(content, **attributes)
        ensure_toc_ids! if generate_toc_ids
      end

      def self.from_json(json, schema: TipTap.default_schema, unknown_node: nil, generate_toc_ids: nil)
        return new(generate_toc_ids: generate_toc_ids.nil? ? true : generate_toc_ids) if json.nil?

        json.deep_stringify_keys!

        policy = unknown_node.nil? ? schema.unknown_node : unknown_node
        content = Array(json["content"]).map do |node|
          klass = schema.resolve_node_class(node["type"], policy: policy)
          klass.from_json(node, schema: schema, unknown_node: policy, generate_toc_ids: generate_toc_ids)
        end

        attrs = Hash(json["attrs"])
        if generate_toc_ids.nil?
          new(content, **attrs)
        else
          new(content, generate_toc_ids: generate_toc_ids, **attrs)
        end
      end

      def text(text, marks: [])
        add_content(Text.new(text, marks: marks))
      end

      def level
        attrs["level"]
      end

      def html_attributes
        # data-toc-id uses a string key — Ruby symbols cannot contain "-".
        {
          "style" => inline_styles,
          "class" => html_class_name,
          "id" => attrs["id"],
          "data-toc-id" => attrs["data-toc-id"]
        }.reject { |key, value| value.blank? }
      end

      def to_markdown(context = Markdown::Context.root)
        heading_level = [level.to_i, 1].max
        prefix = "#" * heading_level
        body = content.map { |node| node.to_markdown(context) }.join.strip
        body.empty? ? prefix : "#{prefix} #{body}"
      end

      private

      def ensure_toc_ids!
        return if attrs["id"].present? && attrs["data-toc-id"].present?

        uuid = attrs["id"].presence || attrs["data-toc-id"].presence || SecureRandom.uuid
        attrs["id"] = uuid if attrs["id"].blank?
        attrs["data-toc-id"] = uuid if attrs["data-toc-id"].blank?
      end
    end
  end
end
