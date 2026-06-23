# frozen_string_literal: true

# Helpers for building a link to Qualtrics
module ContactLinkHelper
  def contact_link
    settings = Rails.configuration.settings
    return settings.default_contact_link unless settings.key?(:qualtrics_survey_link)
    build_contact_link settings.qualtrics_survey_link, repository_id
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
    if params[:f].present? && params[:f]["repository"].present?
      repository_config = Arclight::Repository.find_by(name: params[:f]["repository"].first)
      return repository_config.slug
    end

    @document&.repository_config&.slug # rubocop:disable Rails/HelperInstanceVariable
  end
end
