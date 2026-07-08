# Overrides controller in Arclight 1.6.2 in order to add an about page
# https://github.com/projectblacklight/arclight/blob/main/app/controllers/arclight/repositories_controller.rb

module Arclight
  class RepositoriesController < ApplicationController
    def index
      @repositories = Arclight::Repository.all
      load_collection_counts
    end

    def show
      @repository = Arclight::Repository.find_by!(slug: params[:id])
      redirect_to search_catalog_path(f: { level_ssim: "Collection", repository_ssim: @repository.name }) and return
    end

    def about
      @repository = Arclight::Repository.find_by(slug: params[:id])
    end

    private

    def load_collection_counts
      counts = fetch_collection_counts
      @repositories.each do |repository|
        repository.collection_count = counts[repository.name] || 0
      end
    end

    def fetch_collection_counts
      search_service = Blacklight.repository_class.new(blacklight_config)
      results = search_service.search(
        q: "level_ssim:Collection",
        'facet.field': "repository_ssim",
        rows: 0
      )
      Hash[*results.facet_fields["repository_ssim"]]
    end
  end
end
