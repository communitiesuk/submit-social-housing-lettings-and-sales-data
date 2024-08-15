module MergeRequestsHelper
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
    ]
  end

  def merge_outcomes(merge_request)
    [
      { label: "Total users after merge", value: display_value_or_placeholder(merge_request.total_users), action: { text: "View", href: "#", visually_hidden_text: "total users after merge" } },
      { label: "Total schemes after merge", value: display_value_or_placeholder(merge_request.total_schemes), action: { text: "View", href: "#", visually_hidden_text: "total schemes after merge" } },
      { label: "Total logs after merge", value: merge_request.total_lettings_logs.present? || merge_request.total_sales_logs.present? ? "#{merge_request.total_lettings_logs} lettings logs<br>#{merge_request.total_sales_logs} sales logs".html_safe : display_value_or_placeholder(nil), action: { text: "View", href: "#", visually_hidden_text: "total logs after merge" } },
      { label: "Total stock owners & managing agents after merge", value: merge_request.total_stock_owners.present? || merge_request.total_managing_agents.present? ? "#{merge_request.total_stock_owners} stock owners<br>#{merge_request.total_managing_agents} managing agents".html_safe : display_value_or_placeholder(nil), action: { text: "View", href: "#", visually_hidden_text: "total stock owners & managing agents after merge" } },
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
      organisations_path(anchor: "merge-requests")
    when "merging_organisations"
      absorbing_organisation_merge_request_path(merge_request)
    when "merge_date"
      merging_organisations_merge_request_path(merge_request)
    when "helpdesk_ticket"
      merge_date_merge_request_path(merge_request)
    end
  end

  def merge_request_action(merge_request, page)
    unless merge_request.status == "request_merged" || merge_request.status == "processing"
      { text: "Change", href: send("#{page}_merge_request_path", merge_request, referrer: "check_answers"), visually_hidden_text: page.humanize }
    end
  end
end
