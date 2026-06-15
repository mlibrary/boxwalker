# frozen_string_literal: true

# Helpers for building a link to Qualtrics
module ContactLinkHelper
  def contact_link
    return config.default_contact_link unless config.key?(:qualtrics_survey_link)
    build_contact_link config.qualtrics_survey_link, repository_id
  end

  private

  def build_contact_link(link, repository)
    uri = URI(link)
    unless repository.nil?
      uri.query = "repository=#{repository}"
    end
    uri.to_s
  end

  def repository_id
    if params[:f].present? && params[:f]["repository_sim"].present?
      repository_config = Arclight::Repository.find_by(name: params[:f]["repository_sim"].first)
      return repository_config.slug
    end

    @document&.repository_config&.slug # rubocop:disable Rails/HelperInstanceVariable
  end
end