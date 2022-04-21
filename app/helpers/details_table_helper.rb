module DetailsTableHelper
  def details_html(attribute)
    if attribute[:format] == :bullet
      list = attribute[:value].map { |la| "<li>#{la}</li>"}.join("\n")
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      simple_format(attribute[:value].to_s, {}, wrapper_tag: "div")
    end
  end
end
