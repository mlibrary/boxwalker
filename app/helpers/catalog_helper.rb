module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def has_no_query
    request.path == "/" && params[:q].blank? && params[:f].blank?
  end
end
