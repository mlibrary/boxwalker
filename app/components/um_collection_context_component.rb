# frozen_string_literal: true

class UmCollectionContextComponent < Arclight::CollectionContextComponent
  # Turbo would otherwise fetch these extensionless /pdf and /xml URLs as pages,
  # leaving its progress bar stuck after the browser saves the file (ARC-230).
  def document_download
    render @download_component.new(downloads: collection.downloads, data: { turbo: false })
  end

  def collection_info
    render UmCollectionInfoComponent.new(collection: collection)
  end
end
