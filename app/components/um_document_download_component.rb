# frozen_string_literal: true

# Adds accessible names to Arclight's file-type icons in the Download dropdown.
# Reuses the gem's SVG markup and only injects the accessibility attributes.
class UmDocumentDownloadComponent < Arclight::DocumentDownloadComponent
  def pdf_icon
    labeled_icon(super, "PDF")
  end

  def ead_icon
    labeled_icon(super, "XML")
  end

  private

  def labeled_icon(svg, label)
    svg.to_str.sub("<svg ", %(<svg role="img" aria-label="#{label}" )).html_safe # rubocop:disable Rails/OutputSafety
  end
end
