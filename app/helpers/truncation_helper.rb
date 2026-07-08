module TruncationHelper
  def truncate_html(html_string:, length:)
    truncated = html_string.truncate(length, separator: " ")
    allowed_tags = %w[bold italics emphasis date]
    allowed_attributes = %w[normal] # e.g., <date normal="2050-01-01">
    sanitize(
      truncated,
      tags: allowed_tags,
      attributes: allowed_attributes
    ).html_safe
  end
end
