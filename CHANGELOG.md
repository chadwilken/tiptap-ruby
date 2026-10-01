## [Unreleased]

### Added

- `TipTap::Schema` — first-class node type registry (register, lookup, `use`/`dup`).
- `TipTap::Mark` and built-in mark classes (`TipTap::Marks::*`) registered on Schema.
- Schema mark API: `register_mark` / `mark_for` / `mark_registered?`; `TipTap.mark_for`.
- Optional `schema:` keyword on `Document.from_json` / `Node.from_json` (defaults to `TipTap.default_schema`).
- `TipTap.default_schema` accessor; `TipTap.node_for` / `TipTap.mark_for` read from it.
- Docs: `docs/schema.md`.

### Changed

- `TipTap::Registry` is now a compatibility façade over `TipTap.default_schema` (same public API; optional `register_mark` / `mark_for`).
- `Text` HTML/Markdown rendering composes via schema-registered mark renderers (output for built-ins unchanged).

## [0.10.1] - 2025-11-21

- Add support for Table of Contents

## [0.10.0] - 2025-09-19

- Add support for rendering documents to markdown
- Update rexml for CVE

## [0.9.16] - 2025-04-22

- Update Nokogiri for CVE

## [0.9.15] - 2025-03-05

- Update Nokogiri for CVE

## [0.9.14] - 2025-03-05

- Allow `alt` attribute for `Image` node.

## [0.9.13] - 2025-02-19

- Update Nokogiri for CVE
- require URI explicity in HtmlRenderable
- Force set platform to ruby for Gemfile.lock

## [0.9.12] - 2024-12-20

- Add inline styles when converting headings and paragraphs to HTML

## [0.9.11] - 2024-09-19

- Bump rails-html-sanitizer to 1.6.1 for CVE
- Raise minimum version of ActionText to >= 7.0

## [0.9.9] - 2024-09-19

- Added ordered_list to Document
- Preserve whitespace on Text nodes

## [0.9.8] - 2024-09-10

- Table support (Table, TableRow, TableCell, TableHeader)

## [0.9.6] - 2024-08-06

- Bump rexml version to 3.3.4 for CVE

## [0.9.4] - 2024-07-18

- Ensure that text key is always present when converting document to a hash

## [0.9.0] - 2024-02-20

- Update Nokogiri for security vulnerability

## [0.8.2] - 2023-12-05

- Update documentation and links to point to new GitHub repo at CompanyCam.

## [0.8.0] - 2023-11-02

### Breaking

- Renamed `as_json` to `to_h` details outlined in https://github.com/chadwilken/tiptap-ruby/issues/10.

## [0.7.0] - 2023-11-02

### Breaking

- Renamed `to_json` to `as_json` to follow Ruby/Rails convention.

## [0.6.1] - 2023-11-01

- Allow customizing the `separator` when calling `to_plain_text`.

## [0.6.0] - 2023-11-01

- Implement `Enumerable` for the `HasContent` module.

## [0.5.0] - 2023-10-30

- Make `Text` a subclass of `Node`.
- Try to unify the interface a bit more for the initialize method.

## [0.4.0] - 2023-10-29

- Extract `Registerable` module from `JsonRenderable` so that Node registration is separated from being JSON renderable.
- Make `Document` a subclass of `Node`.

## [0.3.0] - 2023-10-29

- Tweak dependency version requirements to be greater than or equal to

## [0.2.0] - 2023-10-28

- Add `Blockquote` and `Codeblock` nodes
- Add support for `strike`, `code`, and `textStyle` marks

## [0.1.0] - 2023-10-28

- Initial release
