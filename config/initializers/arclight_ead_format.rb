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

    # Override stock Arclight index and table formatting to use h4 for heads
    def format_indexes(node)
      index_head = node.at_css('head')
      index_head&.name = 'h4'
      index_head&.add_class('index-head')
      index_head.presence&.[]=('id', ['index-', index_head.text].join.parameterize)
      format_indexentries(node)
      node.name = 'div'
    end

    def format_table_head(node)
      table_head = node.at_css('head')
      return if table_head.blank?

      table_head.name = 'h4'
      table_head.add_class('table-head')
    end
  end
end
