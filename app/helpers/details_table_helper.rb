module DetailsTableHelper
  def details_html(attribute, resource = nil)
    resource_class = resource.class.name

    if attribute[:format] == :bullet && attribute[:value].length > 1
      list = attribute[:value].map { |value| "<li>#{value}</li>" }.join
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      return simple_format(attribute[:value].first.to_s, { class: "govuk-body" }, wrapper_tag: "p") if attribute[:value].is_a?(Array) && attribute[:value].any?

      value = attribute[:value].presence || case resource_class
                                            when "Location"
                                              LocationPolicy.new(current_user, resource).update? ? govuk_link_to(location_details_link_message(attribute), location_edit_path(resource, attribute[:attribute]), class: "govuk-link govuk-link--no-visited-state") : "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe
                                            when "Organisation"
                                              can_edit_org?(current_user) && attribute[:editable] ? govuk_link_to(organisation_details_link_message(attribute), edit_organisation_path(resource), class: "govuk-link govuk-link--no-visited-state") : "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe
                                            when "Scheme"
                                              can_change_scheme_answer?(attribute[:name], resource) ? govuk_link_to(scheme_details_link_message(attribute), scheme_edit_path(resource, attribute), class: "govuk-link govuk-link--no-visited-state") : "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe
                                            else
                                              "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe
                                            end

      simple_format(value.to_s, { class: "govuk-body" }, wrapper_tag: "p")
    end
  end

  def location_details_html(attribute, location)
    if attribute[:format] == :bullet && attribute[:value].length > 1
      list = attribute[:value].map { |value| "<li>#{value}</li>" }.join
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      return simple_format(attribute[:value].first.to_s, { class: "govuk-body" }, wrapper_tag: "p") if attribute[:value].is_a?(Array) && attribute[:value].any?

      value = attribute[:value].presence || (LocationPolicy.new(current_user, @location).update? ? govuk_link_to(location_details_link_message(attribute), location_edit_path(location, attribute[:attribute]), class: "govuk-link govuk-link--no-visited-state") : "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe)

      simple_format(value.to_s, { class: "govuk-body" }, wrapper_tag: "p")
    end
  end

  def organisation_details_html(attribute, organisation)
    if attribute[:format] == :bullet && attribute[:value].length > 1
      list = attribute[:value].map { |value| "<li>#{value}</li>" }.join
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      return simple_format(attribute[:value].first.to_s, { class: "govuk-body" }, wrapper_tag: "p") if attribute[:value].is_a?(Array) && attribute[:value].any?

      value = attribute[:value].presence || (can_edit_org?(current_user) && attribute[:editable] ? govuk_link_to(organisation_details_link_message(attribute), edit_organisation_path(organisation), class: "govuk-link govuk-link--no-visited-state") : "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe)

      simple_format(value.to_s, { class: "govuk-body" }, wrapper_tag: "p")
    end
  end

  def scheme_details_html(attribute, scheme)
    if attribute[:format] == :bullet && attribute[:value].length > 1
      list = attribute[:value].map { |value| "<li>#{value}</li>" }.join
      simple_format(list, { class: "govuk-list govuk-list--bullet" }, wrapper_tag: "ul")
    else
      return simple_format(attribute[:value].first.to_s, { class: "govuk-body" }, wrapper_tag: "p") if attribute[:value].is_a?(Array) && attribute[:value].any?

      value = attribute[:value].presence || (can_change_scheme_answer?(attribute[:name], scheme) ? govuk_link_to(scheme_details_link_message(attribute), scheme_edit_path(scheme, attribute), class: "govuk-link govuk-link--no-visited-state") : "<span class=\"app-!-colour-muted\">No answer provided</span>".html_safe)

      simple_format(value.to_s, { class: "govuk-body" }, wrapper_tag: "p")
    end
  end
end
