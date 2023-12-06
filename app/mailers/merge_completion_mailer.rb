class MergeCompletionMailer < NotifyMailer
  MERGE_COMPLETION_MERGING_ORGANISATION_TEMPLATE_ID = "b3b62e72-5ced-4515-8720-08bdc7bac792".freeze
  MERGE_COMPLETION_ABSORBING_ORGANISATION_TEMPLATE_ID = "7cdfefac-84c3-4054-8bd9-63103b3847b6".freeze

  def send_merged_organisation_success_mail(email, merged_organisation_name, absorbing_organisation_name, merge_date)
    send_email(
      email,
      MERGE_COMPLETION_MERGING_ORGANISATION_TEMPLATE_ID,
      {
        merged_organisation_name:,
        absorbing_organisation_name:,
        merge_date: merge_date.to_formatted_s(:govuk_date),
        email:,
      },
    )
  end

  def send_absorbing_organisation_success_mail(email, merged_organisations, absorbing_organisation_name, merge_date)
    organisation_count = merged_organisations.count.to_s + " organisation".pluralize(merged_organisations.count)
    pluralised_organisation = merged_organisations.count > 1 ? "these organisations" : "this organisation"
    merged_organisation_list = (merged_organisations.count > 1 ? "The organisations are " : "The organisation is ") + merged_organisations.to_sentence(last_word_connector: " and ")

    send_email(
      email,
      MERGE_COMPLETION_ABSORBING_ORGANISATION_TEMPLATE_ID,
      {
        organisation_count:,
        merged_organisations: merged_organisation_list,
        absorbing_organisation_name:,
        merge_date: merge_date.to_formatted_s(:govuk_date),
        pluralised_organisation:,
      },
    )
  end
end
