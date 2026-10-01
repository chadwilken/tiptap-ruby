# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    # Passthrough for unregistered TipTap node types when the schema
    # (or from_json call) uses unknown_node: :passthrough.
    # Preserves original type, attrs, and recursively parsed content for to_h.
    class Unknown < Node
      attr_reader :original_type

      def initialize(content = [], **attributes)
        @original_type = (
          attributes.delete(:original_type) || attributes.delete("original_type")
        ).to_s
        super(content, **attributes)
      end

      def type_name
        original_type
      end

      def self.from_json(json, schema: TipTap.default_schema, unknown_node: nil, generate_toc_ids: nil)
        json.deep_stringify_keys!

        policy = unknown_node.nil? ? schema.unknown_node : unknown_node
        content = Array(json["content"]).map do |node|
          klass = schema.resolve_node_class(node["type"], policy: policy)
          klass.from_json(node, schema: schema, unknown_node: policy, generate_toc_ids: generate_toc_ids)
        end

        new(content, original_type: json["type"], **Hash(json["attrs"]))
      end

      # Render children only — no inventing a wrapper tag for unknown types.
      def to_html
        safe_join(content.map(&:to_html))
      end

      def to_markdown(context = Markdown::Context.root)
        rendered = content.map { |node| node.to_markdown(context) }.reject(&:blank?)
        rendered.join("\n\n")
      end
    end
  end
end
