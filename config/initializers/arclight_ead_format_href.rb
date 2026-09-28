# frozen_string_literal: true

# UM customization (ARC-190): restore hyperlinking of href-bearing EAD elements.
#
# Stock Arclight's EAD->HTML scrubber (Arclight::EadFormatHelpers) only turns
# extptr/extref/extrefloc/ptr/ref into <a> links and rewrites <title> to <span>,
# discarding any href. UM finding aids frequently encode external links as
# <title href="...">...</title> (e.g. the "Related Material" links to digitized
# interviews). Under stock Arclight those links rendered as plain text.
#
# The previous umich-arclight app carried a customized ead_format_helpers concern
# with a `format_href_attributes` rule that converted ANY element carrying an href
# into an <a target="_blank" class="external-link">. That customization was not
# ported when this app moved to stock Arclight. This override restores it by
# redefining only the scrubber and adding `format_href_attributes`, so the fix
# survives future Arclight upgrades without copying the whole helper.
Rails.application.config.to_prepare do
  Arclight::EadFormatHelpers.module_eval do
    # Order matters: run the ext*/ptr/ref link handling first (so those elements
    # keep their specialized behavior), then convert any remaining href-bearing
    # element (e.g. <title href>) to a link, and only then collapse a bare <title>
    # into a <span>.
    def ead_to_html_scrubber
      Loofah::Scrubber.new do |node|
        format_render_attributes(node) if node.attr("render").present?
        format_links(node) if %w[extptr extref extrefloc ptr ref].include? node.name
        format_href_attributes(node) if node.attr("href").present?
        convert_to_span(node) if Arclight::EadFormatHelpers::CONVERT_TO_SPAN_TAGS.include? node.name
        convert_to_br(node) if Arclight::EadFormatHelpers::CONVERT_TO_BR_TAG.include? node.name
        format_lists(node) if %w[list chronlist].include? node.name
        format_indexes(node) if node.name == "index"
        format_tables(node) if node.name == "table"
        node
      end
    end

    # Convert an element that carries an href (but isn't already an anchor, and
    # wasn't handled by format_links) into an external link. Non-colliding element
    # names are preserved by wrapping so we don't lose their semantics.
    def format_href_attributes(node)
      return if node.name == "a"

      node["target"] = "_blank"
      node["class"] = "external-link"
      node.wrap("<#{node.name}/>") unless Arclight::EadFormatHelpers::CONVERT_TO_SPAN_TAGS.include?(node.name)
      node.name = "a"
    end
  end
end
