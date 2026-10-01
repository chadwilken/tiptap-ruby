# frozen_string_literal: true

# TipTap::Schema is the canonical store for node and mark type registrations.
# TipTap::Registry delegates to TipTap.default_schema for backward compatibility.
module TipTap
  class Schema
    MissingNodeError = Class.new(StandardError)
    MissingMarkError = Class.new(StandardError)

    attr_reader :nodes, :marks

    def initialize(nodes = {}, marks = {})
      @nodes = nodes.transform_keys(&:to_s)
      @marks = marks.transform_keys(&:to_s)
    end

    def register(name, klass)
      nodes[name.to_s] = klass
      klass.install_parent_builders! if klass.respond_to?(:install_parent_builders!)
    end

    def node_for(name)
      nodes.fetch(name.to_s) { raise MissingNodeError, "Unknown node type: #{name}" }
    end

    def registered?(name)
      nodes.key?(name.to_s)
    end

    def register_mark(name, klass)
      marks[name.to_s] = klass
    end

    def mark_for(name)
      marks.fetch(name.to_s) { raise MissingMarkError, "Unknown mark type: #{name}" }
    end

    def mark_registered?(name)
      marks.key?(name.to_s)
    end

    def clear
      nodes.clear
      marks.clear
    end

    # Merge registrations from another schema or from objects that
    # respond to #register(schema). Returns self for chaining.
    def use(*extensions)
      extensions.each do |extension|
        if extension.is_a?(Schema)
          extension.nodes.each { |name, klass| register(name, klass) }
          extension.marks.each { |name, klass| register_mark(name, klass) }
        elsif extension.respond_to?(:register)
          extension.register(self)
        else
          raise ArgumentError, "Extension must be a Schema or respond to #register"
        end
      end
      self
    end

    def dup
      self.class.new(nodes.dup, marks.dup)
    end

    def ==(other)
      other.is_a?(Schema) && nodes == other.nodes && marks == other.marks
    end
  end
end
