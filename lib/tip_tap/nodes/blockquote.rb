# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Blockquote < Node
      self.type_name = "blockquote"
      self.html_tag = :blockquote
      self.html_class_name = "blockquote"

      parent_builder on: TipTap::Document, as: :blockquote, require_block: true

      def to_markdown(context = Markdown::Context.root)
        inner = super(context)
        lines = inner.split("\n", -1)
        quoted = lines.map do |line|
          line.strip.empty? ? ">" : "> #{line}"
        end
        quoted.join("\n")
      end
    end
  end
end
