module RepositoryHelper
  # Modified from UM Arclight/DUL Arclight
  # @return [String] handles the formatting of "city, state zip, country"
  def city_state_zip_country(repository)
    state_zip = repository.state
    state_zip += " #{repository.zip}" if repository.zip
    [ repository.city, state_zip, repository.country ].compact.join(", ")
  end

  def using_materials(repository)
    repository.repo_about&.fetch("using_materials")
  end

  def visitor_info(repository)
    repository.repo_about&.fetch("visitor_info")
  end

  def how_to_request(repository)
    repository.repo_about&.fetch("how_to_request")
  end

  def how_to_order(repository)
    repository.repo_about&.fetch("how_to_order")
  end
end
