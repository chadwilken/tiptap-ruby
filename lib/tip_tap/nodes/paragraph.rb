# frozen_string_literal: true

require "tip_tap/node"

module TipTap
  module Nodes
    class Paragraph < Node
      self.type_name = "paragraph"
      self.html_tag = :p

      # Document allows an empty paragraph (no block); other parents require one.
      parent_builder on: TipTap::Document, as: :paragraph
      parent_builder on: [
        "TipTap::Nodes::ListItem",
        "TipTap::Nodes::Blockquote",
        "TipTap::Nodes::TableCell"
      ], as: :paragraph, require_block: true

      def text(text, marks: [])
        add_content(Text.new(text, marks: marks))
      end

      def to_markdown(context = Markdown::Context.root)
        content.map { |node| node.to_markdown(context) }.join
      end

      # Override the default to_plain_text method to account for the nested Text nodes
      # we don't want to use the separator when joining the text nodes since it could
      # be a newline or some other character that we don't want to include in the plain text
      def to_plain_text(separator: " ")
        content.map { |node| node.to_plain_text(separator: separator) }.join("")
      end
    end
  end
end
