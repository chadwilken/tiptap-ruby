# frozen_string_literal: true

require "active_support/core_ext/hash"

module TipTap
  module HasContent
    include Enumerable

    attr_reader :attrs, :content

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Create a new document or node, optionally passing in attributes (attrs) and nodes
    # @param nodes [Array] An array of nodes to add to this node
    # @param attributes [Hash] A hash of attributes to add to this node e.g. { 'level' => 1 }
    def initialize(content = [], **attributes)
      # This will convert the attrs key to camelcase for example :image_id is converted into 'imageId'
      @attrs = Hash(attributes).deep_transform_keys { |key| key.to_s.camelcase(:lower) }
      @content = content
      yield self if block_given?
    end

    def each
      content.each { |child| yield child }
    end

    def find_node(type_class_or_name)
      node_type = type_class_or_name.is_a?(String) ? TipTap.node_for(type_class_or_name) : type_class_or_name
      find { |child| child.is_a?(node_type) }
    end

    def add_content(node)
      @content << node
    end
    alias_method :<<, :add_content

    def size
      content.size
    end

    def blank?
      content&.all?(&:blank?)
    end

    module ClassMethods
      # Create a new instance from a TipTap JSON object.
      # All nodes are recursively parsed via TipTap.default_schema.
      # @param json [Hash] The JSON object to parse
      # @param unknown_node [Symbol, nil] Override default schema policy: :raise or :passthrough
      # @param generate_toc_ids [Boolean, nil] Forwarded to nested Heading nodes
      def from_json(json, unknown_node: nil, generate_toc_ids: nil)
        return new if json.nil?

        json.deep_stringify_keys!

        schema = TipTap.default_schema
        policy = unknown_node.nil? ? schema.unknown_node : unknown_node

        content = Array(json["content"]).map do |node|
          klass = schema.resolve_node_class(node["type"], policy: policy)
          klass.from_json(node, unknown_node: policy, generate_toc_ids: generate_toc_ids)
        end

        new(content, **Hash(json["attrs"]))
      end
    end
  end
end
