module DetailsTableHelper
  def details_html(attribute)
    if attribute[:format] == :bullet && attribute[:value].length > 1
      list = attribute[:value].map { |value| "<li>#{value}</li>" }.join
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      return simple_format(attribute[:value].first.to_s, { class: "govuk-body" }, wrapper_tag: "p") if attribute[:value].is_a?(Array)

      value = attribute[:value].presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe

      simple_format(value.to_s, { class: "govuk-body" }, wrapper_tag: "p")
    end
  end
end
