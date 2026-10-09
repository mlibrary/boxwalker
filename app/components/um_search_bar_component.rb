# frozen_string_literal: true

class UmSearchBarComponent < Arclight::SearchBarComponent
    def initialize(**kwargs)
      super

      @params[:group] = "true"
    end
end
