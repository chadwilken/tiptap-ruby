# frozen_string_literal: true

require "tip_tap/registry"
require "tip_tap/parent_buildable"

module TipTap
  module Registerable
    def self.included(base)
      base.extend(ClassMethods)
      base.include(ParentBuildable)
    end

    module ClassMethods
      # Setting type_name registers this class on TipTap.default_schema
      # (via the Registry compatibility façade) and installs parent builders.
      def type_name=(type_name)
        @type_name = type_name
        Registry.register(type_name, self)
        install_parent_builders! if respond_to?(:install_parent_builders!)
      end

      def type_name
        @type_name
      end
    end

    def type_name
      self.class.type_name
    end
  end
end
