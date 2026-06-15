# frozen_string_literal: true

# Helper methods specific to DUL ArcLight
# ---------------------------------------
module DulArclightHelper
  # Shorthand to distinguish the homepage among other index presenter driven pages
  def homepage?
    current_page?(root_path) && !has_search_parameters?
  end

  ##
  # @param [SolrDocument]
  def collection_doc(document)
    SolrDocument.find(normalize_id(document.eadid))
  end

  # Model DUL breadcrumb trails after regular_compact_breadcrumbs(), but with these changes:
  # 1) remove repository link; 2) include the top-level series
  # https://github.com/projectblacklight/arclight/blob/master/app/helpers/arclight_helper.rb#L30-L52

  def dul_compact_breadcrumbs(document)
    breadcrumb_links = []
    parents = document_parents(document)
    # breadcrumb_links << parents[0, 2].map do |parent| # DCP2-467: ArcLight - enable full breadcrumb list (option 2)
    breadcrumb_links << parents[0, parents.length].map do |parent|
      link_to parent.label, solr_document_path(parent.global_id)
    end

    # breadcrumb_links << '&hellip;'.html_safe if parents.length > 1 # DCP2-467: ArcLight - enable full breadcrumb list (option 2)

    safe_join(
      breadcrumb_links,
      aria_hidden_breadcrumb_separator
    )
  end

  def meta_tag_description(document)
    [meta_tag_description_context(document), document.short_description].compact.join(' // ')
  end

  # Generate a link to a catalog record using the Aleph ID
  def catalog_item_url(bibnum)
    ['https://find.library.duke.edu/catalog/DUKE', bibnum].join
  end

  # Should I display my scope / abstract in a search result?
  def display_scope?(document)
    document.abstract_or_scope.present? && !collection_result_in_group?(document)
  end

  def ask_librarian_url
    base_url = 'https://www.lib.umich.edu/ask-librarian'
    [base_url, {referrer: request.original_url}.to_param].join('?')
  end

  def request_tooltip(document)
    tooltips = [I18n.t('dul_arclight.views.show.sidebar.request.tooltip')]
    tooltips << I18n.t('dul_arclight.views.show.sidebar.request.multi_aleph') if document.bibnums.count > 1
    if document.containers.present?
      tooltips << I18n.t('dul_arclight.views.show.sidebar.request.current_containers',
                         containers: document.containers.join(', '))
    end
    tooltips.join('<br/><br/>')
  end

  def formatted_last_indexed(timestamp)
    date = DateTime.parse(timestamp)
    date.strftime('%F')
  end

  private

  def collection_result_in_group?(document)
    grouped? && (document.level == 'collection')
  end

  def meta_tag_description_context(document)
    ['In: ', document.parent_labels.join(' > ')].join unless document.level == 'collection'
  end
end
