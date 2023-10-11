class CsvDownloadMailer < NotifyMailer
  CSV_DOWNLOAD_TEMPLATE_ID = "7890e3b9-8c0d-4d08-bafe-427fd7cd95bf".freeze
  CSV_MISSING_LETTINGS_ADDRESSES_DOWNLOAD_TEMPLATE_ID = "7602b6c2-4f44-4da6-8a68-944e39cd8a05".freeze
  CSV_MISSING_SALES_ADDRESSES_DOWNLOAD_TEMPLATE_ID = "1ee6da00-a65e-4a39-b5e5-1846debcb5f8".freeze

  def send_csv_download_mail(user, link, duration)
    send_email(
      user.email,
      CSV_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, link:, duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end

  def send_missing_lettings_addresses_csv_download_mail(user, link, duration, issue_types)
    send_email(
      user.email,
      CSV_MISSING_LETTINGS_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, issue_explanation: issue_explanation(issue_types, "lettings"), how_to_fix: how_to_fix(issue_types, link, "lettings"), duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end

  def send_missing_sales_addresses_csv_download_mail(user, link, duration, issue_types)
    send_email(
      user.email,
      CSV_MISSING_SALES_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, issue_explanation: issue_explanation(issue_types, "sales"), how_to_fix: how_to_fix(issue_types, link, "sales"), duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end

private

  HELPDESK_URL = "https://dluhcdigital.atlassian.net/servicedesk/customer/portal/6/group/11".freeze

  def issue_explanation(issue_types, log_type)
    [
      "We have found #{multiple_issue_types?(issue_types) ? 'these issues' : 'this issue'} in your logs imported to the new version of CORE:\n",
      issue_types.include?("missing_address") ? "## Full address required\nThe Unique Property Reference number (UPRN) in some logs is incorrect, so the address data was not imported. Provide the full address and leave the UPRN column blank.\n" : "",
      issue_types.include?("missing_town") ? "## Missing town or city\nThe town or city in some logs is missing. This data is required in the new version of CORE.\n" : "",
      has_uprn_issues(issue_types) ? uprn_issue_explanation(issue_types, log_type) : "",
    ].join("")
  end

  def how_to_fix(issue_types, link, log_type)
    [
      "You need to:\n\n",
      "- download [this spreadsheet for #{log_type} logs](#{link}). This link will expire in one week. To request another link, [contact the CORE helpdesk](#{HELPDESK_URL}).\n",
      issue_types.include?("missing_address") || issue_types.include?("missing_town") ? "- fill in the missing address data\n" : "",
      uprn_issues_only(issue_types) ? "- check that the address data is correct\n" : "- check that the existing address data is correct\n",
      has_uprn_issues(issue_types) ? "- correct any address errors\n" : "",
    ].join("")
  end

  def uprn_issues_only(issue_types)
    issue_types == %w[wrong_uprn] || issue_types == %w[bristol_uprn] || issue_types.count == 2 && issue_types.include?("wrong_uprn") && issue_types.include?("bristol_uprn")
  end

  def has_uprn_issues(issue_types)
    issue_types.include?("wrong_uprn") || issue_types.include?("bristol_uprn")
  end

  def multiple_issue_types?(issue_types)
    issue_types.count > 1 && !uprn_issues_only(issue_types) || issue_types.count > 2
  end

  def uprn_issue_explanation(issue_types, log_type)
    if issue_types.include?("wrong_uprn") && !issue_types.include?("bristol_uprn")
      "## Incorrect UPRN\nThe UPRN in some logs may be incorrect, so the wrong address data may have been imported.

In some of your logs, the UPRN is the same as the #{log_type == 'lettings' ? 'tenant code or property reference' : 'purchaser code'}, but these are different things. #{log_type == 'lettings' ? 'Property references' : 'Purchaser codes'} are codes that your organisation uses to identify properties. UPRNs are unique numbers assigned by the Ordnance Survey.

If a log has the correct UPRN, leave the UPRN unchanged. If the UPRN is incorrect, clear the value and provide the full address instead. Alternatively, you can change the UPRN on the CORE system.\n"
    elsif issue_types.include?("bristol_uprn") && !issue_types.include?("wrong_uprn")
      "## Incorrect UPRN\nThe UPRN in some logs may be incorrect, so the wrong address data may have been imported. In some of your logs, the UPRN links to an address in Bristol, but this is the first time your organisation has submitted logs for properties in Bristol.

If a log has the correct UPRN, leave the UPRN unchanged. If the UPRN is incorrect, clear the value and provide the full address instead. Alternatively, you can change the UPRN on the CORE system.\n"
    else
      "## Incorrect UPRN\nThe UPRN in some logs may be incorrect, so the wrong address data may have been imported. We think this is an issue for two reasons.

In some of your logs, the UPRN links to an address in Bristol, but this is the first time your organisation has submitted logs for properties in Bristol.

In other logs, the UPRN is the same as the #{log_type == 'lettings' ? 'tenant code or property reference' : 'purchaser code'}, but these are different things. #{log_type == 'lettings' ? 'Property references' : 'Purchaser codes'} are codes that your organisation uses to identify properties. UPRNs are unique numbers assigned by the Ordnance Survey.

If a log has the correct UPRN, leave the UPRN unchanged. If the UPRN is incorrect, clear the value and provide the full address instead. Alternatively, you can change the UPRN on the CORE system."
    end
  end
end
