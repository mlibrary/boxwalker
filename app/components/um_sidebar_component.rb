# frozen_string_literal: true

class UmSidebarComponent < Arclight::SidebarComponent
  def collection_sidebar
    render UmCollectionSidebarComponent.new(
      document: document,
      collection_presenter: document_presenter(document.collection),
      partials: blacklight_config.show.metadata_partials
    )
  end
end