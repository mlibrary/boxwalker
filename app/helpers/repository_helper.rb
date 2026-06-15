module RepositoryHelper
  # Modified from UM Arclight/DUL Arclight
  # @return [String] handles the formatting of "city, state zip, country"
  def city_state_zip_country(repository)
    state_zip = repository.state
    state_zip += " #{repository.zip}" if repository.zip
    [ repository.city, state_zip, repository.country ].compact.join(", ")
  end
end