module DataSharingAgreementHelper
  def data_sharing_agreement_row(user:, organisation:, summary_list:)
    summary_list.with_row do |row|
      row.with_key { "Data Sharing Agreement" }
      row.with_action(
        href: data_sharing_agreement_organisation_path(organisation),
        text: "View agreement",
      )

      row.with_value do
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

  def name_for_data_sharing_agreement(data_protection_confirmation, user)
    if data_protection_confirmation&.confirmed?
      data_protection_confirmation.data_protection_officer_name
    elsif user.is_dpo?
      user.name
    else
      "[DPO name]"
    end
  end

  def org_name_for_data_sharing_agreement(data_protection_confirmation, user)
    if data_protection_confirmation&.confirmed?
      data_protection_confirmation.organisation_name
    else
      user.organisation.name
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def present_section_12_2(data_protection_confirmation:, user:, organisation:)
    if data_protection_confirmation&.confirmed?
      @org_address = data_protection_confirmation.organisation_address
      @org_name = data_protection_confirmation.organisation_name
      @org_phone = data_protection_confirmation.organisation_phone_number
      @dpo_name = data_protection_confirmation.data_protection_officer_name
      @dpo_email = data_protection_confirmation.data_protection_officer_email
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

    if data_protection_confirmation&.confirmed? && @dpo_email.exclude?("@") # Do not show invalid email addresses
      "12.2. For #{@org_name}: Name: #{@dpo_name}, Postal Address: #{@org_address}, Telephone number: #{@org_phone}"
    else
      "12.2. For #{@org_name}: Name: #{@dpo_name}, Postal Address: #{@org_address}, E-mail address: #{@dpo_email}, Telephone number: #{@org_phone}"
    end
  end
# rubocop:enable Rails/HelperInstanceVariable

private

  def data_sharing_agreement_first_line(organisation:, user:)
    return "Not accepted" unless organisation.data_protection_confirmed?

    if user.support?
      "Accepted #{organisation.data_protection_confirmation.signed_at.strftime('%d/%m/%Y')}"
    else
      "Accepted"
    end
  end

  def data_sharing_agreement_second_line(organisation:, user:)
    if organisation.data_protection_confirmed?
      organisation.data_protection_confirmation.data_protection_officer_name if user.support?
    else
      "Data protection officer must sign" unless user.is_dpo?
    end
  end
end
