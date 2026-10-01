# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Codeblock < Node
      self.type_name = "codeBlock"
      self.html_tag = :pre

      parent_builder on: TipTap::Document, as: :codeblock, require_block: true

      # Special-cased: builds a Text node with a code mark (not a child node type builder).
      def code(text)
        add_content(Text.new(text, marks: [{type: "code"}]))
      end

      def to_markdown(context = Markdown::Context.root)
        fence_language = attrs["language"].presence || attrs["lang"].presence
        fence_header = "```#{fence_language}"
        code_context = context.with_code_block
        body = content.map { |node| node.to_markdown(code_context) }.join
        body = "#{body}\n" unless body.end_with?("\n") || body.empty?
        "#{fence_header}\n#{body}```"
      end
    end
  end
end
