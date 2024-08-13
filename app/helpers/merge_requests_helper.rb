module MergeRequestsHelper
  def display_value_or_placeholder(value, placeholder = "You didn't answer this question")
    value.presence || content_tag(:span, placeholder, class: "app-!-colour-muted")
  end

  def request_details(merge_request)
    [
      { label: "Requester", value: display_value_or_placeholder(merge_request.requester&.name) },
      { label: "Helpdesk ticket", value: merge_request.helpdesk_ticket.present? ? link_to("#{merge_request.helpdesk_ticket} (opens in a new tab)", "https://dluhcdigital.atlassian.net/browse/#{merge_request.helpdesk_ticket}", target: "_blank", rel: "noopener noreferrer") : display_value_or_placeholder(nil), action: merge_request.status == "request_merged" ? nil : { text: "Change", href: "#", visually_hidden_text: "helpdesk ticket" } },
      { label: "Status", value: status_tag(merge_request.status) },
    ]
  end

  def merge_details(merge_request)
    [
      { label: "Absorbing organisation", value: display_value_or_placeholder(merge_request.absorbing_organisation_name), action: merge_request.status == "request_merged" ? nil : { text: "Change", href: absorbing_organisation_merge_request_path(merge_request), visually_hidden_text: "absorbing organisation" } },
      { label: "Merging organisations", value: merge_request.merge_request_organisations.any? ? merge_request.merge_request_organisations.map(&:merging_organisation_name).join("<br>").html_safe : display_value_or_placeholder(nil), action: merge_request.status == "request_merged" ? nil : { text: "Change", href: organisations_merge_request_path(merge_request), visually_hidden_text: "merging organisations" } },
      { label: "Merge date", value: display_value_or_placeholder(merge_request.merge_date), action: merge_request.status == "request_merged" ? nil : { text: "Change", href: merge_date_merge_request_path(merge_request), visually_hidden_text: "merge date" } },
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
end
