module MergeRequestsHelper
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper

  def display_value_or_placeholder(value, placeholder = "You didn't answer this question")
    value.presence || content_tag(:span, placeholder, class: "app-!-colour-muted")
  end

  def request_details(merge_request)
    [
      { label: "Requester", value: display_value_or_placeholder(merge_request.requester&.name) },
      { label: "Helpdesk ticket", value: merge_request.helpdesk_ticket.present? ? link_to("#{merge_request.helpdesk_ticket} (opens in a new tab)", "https://dluhcdigital.atlassian.net/browse/#{merge_request.helpdesk_ticket}", target: "_blank", rel: "noopener noreferrer") : display_value_or_placeholder(nil), action: merge_request_action(merge_request, "helpdesk_ticket") },
      { label: "Status", value: status_tag(merge_request.status) },
    ]
  end

  def merge_details(merge_request)
    [
      { label: "Absorbing organisation", value: display_value_or_placeholder(merge_request.absorbing_organisation_name), action: merge_request_action(merge_request, "absorbing_organisation") },
      { label: "Merging organisations", value: merge_request.merge_request_organisations.any? ? merge_request.merge_request_organisations.map(&:merging_organisation_name).join("<br>").html_safe : display_value_or_placeholder(nil), action: merge_request_action(merge_request, "merging_organisations") },
      { label: "Merge date", value: display_value_or_placeholder(merge_request.merge_date), action: merge_request_action(merge_request, "merge_date") },
      { label: "Absorbing organisation already active?", value: display_value_or_placeholder(merge_request.existing_absorbing_organisation_label), action: merge_request_action(merge_request, "existing_absorbing_organisation") },
    ]
  end

  def merge_outcomes(merge_request)
    [
      { label: "Total users after merge", value: display_value_or_placeholder(merge_request.total_users_label), action: merge_outcome_action(merge_request, "user_outcomes") },
      { label: "Total schemes after merge", value: display_value_or_placeholder(merge_request.total_schemes_label), action: merge_outcome_action(merge_request, "scheme_outcomes") },
      { label: "Total logs after merge", value: merge_request.total_lettings_logs.present? || merge_request.total_sales_logs.present? ? "#{merge_request.total_lettings_logs} lettings logs<br>#{merge_request.total_sales_logs} sales logs".html_safe : display_value_or_placeholder(nil), action: { text: "View", href: "#", visually_hidden_text: "total logs after merge" } },
      { label: "Total stock owners & managing agents after merge", value: display_value_or_placeholder(merge_request.total_stock_owners_managing_agents_label), action: merge_outcome_action(merge_request, "relationship_outcomes") },
    ]
  end

  def ordered_merging_organisations(merge_request, new_merging_org_ids)
    Organisation.where(id: new_merging_org_ids) + merge_request.merge_request_organisations.order(created_at: :desc).map(&:merging_organisation)
  end

  def submit_merge_request_button_text(referrer)
    if accessed_from_check_answers?(referrer)
      "Save changes"
    else
      "Save and continue"
    end
  end

  def secondary_merge_request_link_text(referrer, skip_for_now: false)
    if accessed_from_check_answers?(referrer)
      "Cancel"
    elsif skip_for_now
      "Skip for now"
    else
      ""
    end
  end

  def accessed_from_check_answers?(referrer)
    %w[check_answers].include?(referrer)
  end

  def merge_request_back_link(merge_request, page, referrer)
    return merge_request_path(merge_request) if accessed_from_check_answers?(referrer)

    case page
    when "absorbing_organisation"
      organisations_path(tab: "merge-requests")
    when "merging_organisations"
      absorbing_organisation_merge_request_path(merge_request)
    when "merge_date"
      merging_organisations_merge_request_path(merge_request)
    when "existing_absorbing_organisation"
      merge_date_merge_request_path(merge_request)
    when "helpdesk_ticket"
      existing_absorbing_organisation_merge_request_path(merge_request)
    end
  end

  def merge_request_action(merge_request, page)
    unless merge_request.status == "request_merged" || merge_request.status == "processing"
      { text: "Change", href: send("#{page}_merge_request_path", merge_request, referrer: "check_answers"), visually_hidden_text: page.humanize }
    end
  end

  def merge_outcome_action(merge_request, page)
    unless merge_request.status == "request_merged" || merge_request.status == "processing"
      { text: "View", href: send("#{page}_merge_request_path", merge_request), visually_hidden_text: page.humanize }
    end
  end

  def submit_merge_request_url(referrer)
    referrer == "check_answers" ? merge_request_path(referrer: "check_answers") : merge_request_path
  end

  def merging_organisations_without_users_text(organisations)
    return "" unless organisations.count.positive?

    if organisations.count == 1
      "#{organisations.first.name} has no users."
    else
      "#{organisations.map(&:name).to_sentence} have no users."
    end
  end

  def link_to_merging_organisation_users(organisation)
    count_text = organisation.users.count == 1 ? "1 #{organisation.name} user" : "all #{organisation.users.count} #{organisation.name} users"
    govuk_link_to "View #{count_text} (opens in a new tab)", users_organisation_path(organisation), target: "_blank"
  end

  def total_users_after_merge_text(merge_request)
    count = merge_request.total_visible_users_after_merge
    "#{"#{count} user".pluralize(count)} after merge"
  end

  def total_stock_owners_after_merge_text(merge_request)
    count = merge_request.total_stock_owners_after_merge
    "#{"#{count} stock owner".pluralize(count)} after merge"
  end

  def total_managing_agents_after_merge_text(merge_request)
    count = merge_request.total_managing_agents_after_merge
    "#{"#{count} managing agent".pluralize(count)} after merge"
  end

  def related_organisations(merge_request, relationship_type)
    organisations =  merge_request.absorbing_organisation.send(relationship_type.pluralize).visible + merge_request.merging_organisations.flat_map { |org| org.send(relationship_type.pluralize).visible }
    organisations += [merge_request.absorbing_organisation] + merge_request.merging_organisations
    organisations.group_by { |relationship| relationship }.select { |_, occurrences| occurrences.size > 1 }.keys
  end

  def related_organisations_text(merge_request, relationship_type)
    if related_organisations(merge_request, relationship_type).any?
      "Some of the organisations merging have common #{relationship_type.humanize(capitalize: false).pluralize}.<br><br>"
    else
      ""
    end
  end

  def organisations_without_relationships(merge_request, relationship_type)
    ([merge_request.absorbing_organisation] + merge_request.merging_organisations).select { |org| org.send(relationship_type.pluralize).visible.empty? }
  end

  def organisations_without_relationships_text(organisations_without_relationships, relationship_type)
    return "" unless organisations_without_relationships.any?

    org_names = organisations_without_relationships.map(&:name).to_sentence
    verb = organisations_without_relationships.count > 1 ? "have" : "has"
    "#{org_names} #{verb} no #{relationship_type.humanize(capitalize: false).pluralize}.<br><br>"
  end

  def generate_organisation_link_text(organisation_count, org, relationship_type)
    "View #{organisation_count == 1 ? 'the' : 'all'} #{organisation_count} #{org.name} #{relationship_type.humanize(capitalize: false).pluralize(organisation_count)} (opens in a new tab)"
  end

  def relationship_text(merge_request, relationship_type, organisation_path_helper)
    text = ""
    organisations_without_relationships = organisations_without_relationships(merge_request, relationship_type)

    text += related_organisations_text(merge_request, relationship_type)
    text += organisations_without_relationships_text(organisations_without_relationships, relationship_type)

    ([merge_request.absorbing_organisation] + merge_request.merging_organisations).each do |org|
      organisation_count = org.send(relationship_type.pluralize).visible.count
      next if organisation_count.zero?

      link_text = generate_organisation_link_text(organisation_count, org, relationship_type)
      text += "#{govuk_link_to(link_text, send(organisation_path_helper, org), target: '_blank')}<br><br>"
    end

    text.html_safe
  end

  def stock_owners_text(merge_request)
    relationship_text(merge_request, "stock_owner", :stock_owners_organisation_path)
  end

  def managing_agent_text(merge_request)
    relationship_text(merge_request, "managing_agent", :managing_agents_organisation_path)
  end

  def merging_organisations_without_schemes_text(organisations)
    return "" unless organisations.count.positive?

    if organisations.count == 1
      "#{organisations.first.name} has no schemes."
    else
      "#{organisations.map(&:name).to_sentence} have no schemes."
    end
  end

  def link_to_merging_organisation_schemes(organisation)
    count_text = organisation.owned_schemes.count == 1 ? "1 #{organisation.name} scheme" : "all #{organisation.owned_schemes.count} #{organisation.name} schemes"
    govuk_link_to "View #{count_text} (opens in a new tab)", schemes_organisation_path(organisation), target: "_blank"
  end

  def total_schemes_after_merge_text(merge_request)
    count = merge_request.total_visible_schemes_after_merge
    "#{"#{count} scheme".pluralize(count)} after merge"
  end
end
