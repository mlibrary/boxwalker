module Arclight
  class RepositoriesController < ApplicationController

    def about
      @repository = Arclight::Repository.find_by(slug: params[:id])
    end
  end
end
