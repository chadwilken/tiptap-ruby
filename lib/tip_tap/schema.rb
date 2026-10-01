# frozen_string_literal: true

# TipTap::Schema is the canonical store for node type registrations.
# TipTap::Registry delegates to TipTap.default_schema for backward compatibility.
module TipTap
  class Schema
    MissingNodeError = Class.new(StandardError)

    attr_reader :nodes

    def initialize(nodes = {})
      @nodes = nodes.transform_keys(&:to_s)
    end

    def register(name, klass)
      nodes[name.to_s] = klass
    end

    def node_for(name)
      nodes.fetch(name.to_s) { raise MissingNodeError, "Unknown node type: #{name}" }
    end

    def registered?(name)
      nodes.key?(name.to_s)
    end

    def clear
      nodes.clear
    end

    # Merge node registrations from another schema or from objects that
    # respond to #register(schema). Returns self for chaining.
    def use(*extensions)
      extensions.each do |extension|
        if extension.is_a?(Schema)
          extension.nodes.each { |name, klass| register(name, klass) }
        elsif extension.respond_to?(:register)
          extension.register(self)
        else
          raise ArgumentError, "Extension must be a Schema or respond to #register"
        end
      end
      self
    end

    def dup
      self.class.new(nodes.dup)
    end

    def ==(other)
      other.is_a?(Schema) && nodes == other.nodes
    end
  end
end
