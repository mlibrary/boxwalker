# frozen_string_literal: true

module UMArclightHelper
  # Shorthand to distinguish the homepage among other index presenter driven pages
  def homepage?
    current_page?(root_path) && !has_search_parameters?
  end

  def formatted_last_indexed(timestamp)
    date = DateTime.parse(timestamp)
    date.strftime("%F")
  end
end
