class MergeCompletionMailer < NotifyMailer
  MERGE_COMPLETION_MERGING_ORGANISATION_TEMPLATE_ID = "b3b62e72-5ced-4515-8720-08bdc7bac792".freeze
  MERGE_COMPLETION_ABSORBING_ORGANISATION_TEMPLATE_ID = "xxx".freeze

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

  def send_absorbing_organisation_success_mail(email, merged_organisation_name, absorbing_organisation_name, merge_date)
    send_email(
      email,
      MERGE_COMPLETION_ABSORBING_ORGANISATION_TEMPLATE_ID,
      {
        merged_organisation_name:,
        absorbing_organisation_name:,
        merge_date: merge_date.to_formatted_s(:govuk_date),
        email:,
      },
    )
  end
end
