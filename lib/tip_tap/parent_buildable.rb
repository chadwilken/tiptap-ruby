# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

module TipTap
  # Declares builder methods on parent node classes when a child node type is registered.
  #
  #   class Paragraph < Node
  #     parent_builder on: TipTap::Document, as: :paragraph
  #     parent_builder on: [ListItem, Blockquote], as: :paragraph, require_block: true
  #   end
  #
  #   class Heading < Node
  #     parent_builder on: TipTap::Document, as: :heading, require_block: true, args: {level: 1}
  #   end
  #
  #   class Image < Node
  #     parent_builder on: TipTap::Document, as: :image, args: [:src]
  #   end
  module ParentBuildable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def parent_builders
        @parent_builders ||= []
      end

      # @param on [Class, String, Array] parent class(es) that receive the builder
      # @param as [Symbol, String] method name on the parent (default: demodulized underscore name)
      # @param require_block [Boolean] raise ArgumentError when no block is given
      # @param args [Hash, Array] default kwargs (Hash) and/or required keyword names (Array)
      def parent_builder(on:, as: nil, require_block: false, args: {})
        method_name = (as || name.demodulize.underscore).to_sym
        defaults, required_keywords = normalize_builder_args(args)

        parent_builders << {
          parents: Array(on),
          method_name: method_name,
          require_block: require_block,
          defaults: defaults,
          required_keywords: required_keywords
        }

        install_parent_builders!
      end

      def install_parent_builders!
        parent_builders.each do |declaration|
          declaration[:parents].each do |parent|
            parent_class = resolve_parent_class(parent)
            next if parent_class.nil?

            ParentBuilderInstaller.install(
              parent_class,
              child_class: self,
              method_name: declaration[:method_name],
              require_block: declaration[:require_block],
              defaults: declaration[:defaults],
              required_keywords: declaration[:required_keywords]
            )
          end
        end
      end

      private

      def normalize_builder_args(args)
        case args
        when Hash
          [args.transform_keys(&:to_sym), []]
        when Array
          [{}, args.map(&:to_sym)]
        else
          raise ArgumentError, "args must be a Hash of defaults or an Array of required keywords"
        end
      end

      def resolve_parent_class(parent)
        case parent
        when Class
          parent
        when String, Symbol
          parent.to_s.constantize
        end
      rescue NameError
        nil
      end
    end
  end

  # Installs generated builder methods onto a parent via an included module (idempotent).
  module ParentBuilderInstaller
    MODULE_NAME = :TipTapParentBuilders

    module_function

    def install(parent_class, child_class:, method_name:, require_block:, defaults:, required_keywords:)
      mod = builder_module_for(parent_class)
      owners = mod.instance_variable_get(:@tiptap_builder_owners) || {}
      return if owners[method_name] == child_class

      owners[method_name] = child_class
      mod.instance_variable_set(:@tiptap_builder_owners, owners)

      child = child_class
      needs_block = require_block
      default_attrs = defaults.dup.freeze
      required = required_keywords.dup.freeze

      mod.define_method(method_name) do |**kwargs, &block|
        raise ArgumentError, "Block required" if needs_block && block.nil?

        missing = required.reject { |key| kwargs.key?(key) }
        if missing.any?
          label = (missing.size == 1) ? "missing keyword" : "missing keywords"
          raise ArgumentError, "#{label}: #{missing.map(&:inspect).join(", ")}"
        end

        add_content(child.new(**default_attrs.merge(kwargs), &block))
      end

      parent_class.include(mod) unless parent_class.included_modules.include?(mod)
    end

    def builder_module_for(parent_class)
      if parent_class.const_defined?(MODULE_NAME, false)
        parent_class.const_get(MODULE_NAME, false)
      else
        parent_class.const_set(MODULE_NAME, Module.new)
      end
    end
  end
end
