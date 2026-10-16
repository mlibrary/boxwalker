class UmIndexPresenter < Arclight::IndexPresenter
  GROUP_HEADER_DUPLICATE_FIELDS = %w[creator abstract_or_scope].freeze

  def field_presenters(document_fields = fields, **kwargs, &block)
    return super unless suppress_group_header_duplicates?

    filtered = document_fields.reject { |key, _| GROUP_HEADER_DUPLICATE_FIELDS.include?(key) }
    super(filtered, **kwargs, &block)
  end

  private

  def suppress_group_header_duplicates?
    view_context.respond_to?(:grouped?) && view_context.grouped? && document.collection?
  end
end
