# frozen_string_literal: true

Rails.application.config.to_prepare do
  Arclight::EadFormatHelpers.module_eval do
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
        format_compound_elements(node) if %w[separatedmaterial relatedmaterial bibliography].include? node.name
        node
      end
    end

    def format_href_attributes(node)
      return if node.name == "a"

      node["target"] = "_blank"
      node["class"] = "external-link"
      node.wrap("<#{node.name}/>") unless Arclight::EadFormatHelpers::CONVERT_TO_SPAN_TAGS.include?(node.name)
      node.name = "a"
    end

    def format_compound_elements(node)
      head = node.xpath("./head").first
      head.name = "h3" if !head.nil?
      return if head.present?
      label = I18n.t("um_arclight.ead_element_labels.#{node.name}")
      node.add_previous_sibling("<h3>#{label}</h3>")
    end
  end
end
