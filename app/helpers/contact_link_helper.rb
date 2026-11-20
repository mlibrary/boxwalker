# frozen_string_literal: true

# Helper for the "Contact Us" link in the universal footer.
# Uses the Qualtrics survey link from ArgoCD (QUALTRICS_SURVEY_LINK)
# Use this helper to integrate survey_link into error and other help pages
module ContactLinkHelper
  FALLBACK_CONTACT_LINK = "mailto:digital-collections-help@umich.edu"

  def contact_link
    Rails.configuration.settings[:qualtrics_survey_link].presence || default_contact_link
  end

  private

  def default_contact_link
    Rails.configuration.settings[:default_contact_link].presence || FALLBACK_CONTACT_LINK
  end
end
