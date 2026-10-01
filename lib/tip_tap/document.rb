# frozen_string_literal: true

require "tip_tap/node"

# This is the class that all child nodes will be added to.
# This is the root object for TipTap.
# Child builder methods (paragraph, heading, …) are installed via
# each child node's `parent_builder` declaration.
module TipTap
  class Document < Node
    self.type_name = "doc"
    self.html_tag = :div
    self.html_class_name = "tiptap-document"
  end
end
