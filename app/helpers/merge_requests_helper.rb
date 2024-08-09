module MergeRequestsHelper
  def display_value_or_placeholder(value, placeholder = "You didn't answer this question")
    value.presence || content_tag(:span, placeholder, class: "app-!-colour-muted")
  end
end
