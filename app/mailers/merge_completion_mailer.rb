class MergeCompletionMailer < NotifyMailer
  MERGE_COMPLETION_TEMPLATE_ID = "xxx".freeze

  def send_merge_completion_mail(email, merged_organisation_name, absorbing_organisation_name, merge_date, username)
    send_email(
      email,
      MERGE_COMPLETION_TEMPLATE_ID,
      {
        merged_organisation_name:,
        absorbing_organisation_name:,
        merge_date:,
        email:,
        username:,
      },
    )
  end
end
