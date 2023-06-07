module DataSharingAgreementHelper
  def data_sharing_agreement_row(user:, organisation:, summary_list:)
    summary_list.row do |row|
      row.key { "Data Sharing Agreement" }
      row.action(
        href: data_sharing_agreement_organisation_path(organisation),
        text: "View agreement",
      )

      row.value do
        simple_format(
          data_sharing_agreement_first_line(organisation:, user:),
          wrapper_tag: "span",
          class: "govuk-!-margin-right-4",
        ) + simple_format(
          data_sharing_agreement_second_line(organisation:, user:),
          wrapper_tag: "span",
          class: "govuk-!-font-weight-regular app-!-colour-muted",
        )
      end
    end
  end

  def name_for_data_sharing_agreement(data_sharing_agreement, user)
    if data_sharing_agreement.present?
      data_sharing_agreement.data_protection_officer.name
    elsif user.is_dpo?
      user.name
    else
      "[DPO name]"
    end
  end

  def org_name_for_data_sharing_agreement(data_sharing_agreement, user)
    if data_sharing_agreement.present?
      data_sharing_agreement.organisation_name
    else
      user.organisation.name
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def section_12_2(data_sharing_agreement:, user:, organisation:)
    if data_sharing_agreement
      @org_address = data_sharing_agreement.organisation_address
      @org_name = data_sharing_agreement.organisation_name
      @org_phone = data_sharing_agreement.organisation_phone_number
      @dpo_name = data_sharing_agreement.dpo_name
      @dpo_email = data_sharing_agreement.dpo_email
    else
      @org_name = organisation.name
      @org_address = organisation.address_row
      @org_phone = organisation.phone

      if user.is_dpo?
        @dpo_name = user.name
        @dpo_email = user.email
      else
        @dpo_name = "[DPO name]"
        @dpo_email = "[DPO email]"
      end
    end

    "12.2. For #{@org_name}: Name: #{@dpo_name}, Postal Address: #{@org_address}, E-mail address: #{@dpo_email}, Telephone number: #{@org_phone}"
  end
# rubocop:enable Rails/HelperInstanceVariable

private

  def data_sharing_agreement_first_line(organisation:, user:)
    return "Not accepted" if organisation.data_sharing_agreement.blank?

    if user.support?
      "Accepted #{organisation.data_sharing_agreement.signed_at.strftime('%d/%m/%Y')}"
    else
      "Accepted"
    end
  end

  def data_sharing_agreement_second_line(organisation:, user:)
    if organisation.data_sharing_agreement.present?
      organisation.data_sharing_agreement.data_protection_officer.name if user.support?
    else
      "Data protection officer must sign" unless user.is_dpo?
    end
  end
end
