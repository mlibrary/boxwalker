class UmCollectionContextComponent < Arclight::CollectionContextComponent
  def collection_info
    render UmCollectionInfoComponent.new(collection: collection)
  end
end