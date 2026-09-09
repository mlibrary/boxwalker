module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def has_no_query
    request.path == "/" &&
      params[:q].blank? &&
      params[:f].blank? &&
      !advanced_search_clauses?
  end

  private

  # Advanced search sends `clause[...][query]` params instead of `q`.
  def advanced_search_clauses?
    clauses = params[:clause]
    return false if clauses.blank?

    values = clauses.respond_to?(:values) ? clauses.values : clauses
    values.any? { |clause| clause[:query].present? }
  end
end