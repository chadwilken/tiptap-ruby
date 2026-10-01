# frozen_string_literal: true

require "tip_tap/schema"

# Compatibility façade over TipTap.default_schema.
# Prefer TipTap::Schema (and TipTap.default_schema) for new code.
# TipTap::Registry.register / node_for / clear / registry still work.
module TipTap
  class Registry
    MissingNodeError = Schema::MissingNodeError
    MissingMarkError = Schema::MissingMarkError

    def self.register(name, klass)
      TipTap.default_schema.register(name, klass)
    end

    def self.node_for(name)
      TipTap.default_schema.node_for(name)
    end

    def self.register_mark(name, klass)
      TipTap.default_schema.register_mark(name, klass)
    end

    def self.mark_for(name)
      TipTap.default_schema.mark_for(name)
    end

    def self.clear
      TipTap.default_schema.clear
    end

    def self.registry
      TipTap.default_schema.nodes
    end
  end
end
