module TruncationHelper
  def truncate_html(html_string:, length:)
    omission = "..."
    fragment = Nokogiri::HTML::DocumentFragment.parse(html_string)
    p fragment
    truncated_node = nokogiri_truncate(fragment, length, omission)
    truncated_node.inner_html
  end

  private
  def nokogiri_truncate(node, max_length, omission)
    # p "Node"
    # p node
    # p node.inner_html

    if node.kind_of?(Nokogiri::XML::Text)
      if node.content.length >= max_length
        first_word_length = node.content.split.first.length

        allowed_endpoint = max_length - omission.length
        if first_word_length > allowed_endpoint
          nil
        else
          allowed_endpoint = node.content.rindex(" ", allowed_endpoint) || allowed_endpoint
          sliced = node.content.slice(0, allowed_endpoint)
          Nokogiri::XML::Text.new(sliced, node.parent)
        end
      else
        node.dup
      end
    else
      return node if node.inner_text.nil? || node.inner_text.length <= max_length

      new_node = node.dup
      new_node.children.remove
      remaining_length = max_length

      node.children.each do |child|
        if remaining_length <= 0
          break
        end
        truncation_result = nokogiri_truncate(child, remaining_length, omission)
        # If the result is nil and its the only child, then
        if truncation_result.nil? && node.children.length == 1
          return Nokogiri::XML::Text.new(omission, node.parent)
        end
        new_node.add_child(truncation_result)
        remaining_length = remaining_length - child.inner_text.length
      end
      new_node
    end
  end
end
