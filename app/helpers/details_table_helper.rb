module DetailsTableHelper
  def details_html(attribute)
    if attribute[:format] == :bullet && attribute[:value].length > 1
      list = attribute[:value].map { |value| "<li>#{value}</li>" }.join
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      value = attribute[:value].is_a?(Array) ? attribute[:value].first : attribute[:value]

      simple_format(value.to_s, { class: "govuk-body" }, wrapper_tag: "p")
    end
  end
end
