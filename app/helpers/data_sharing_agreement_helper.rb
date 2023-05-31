module DataSharingAgreementHelper
  def data_sharing_agreement_row(user:, organisation:, summary_list:)
    summary_list.row do |row|
      row.key { "Data Sharing Agreement" }
      row.value { organisation.data_sharing_agreement.present? ? "Accepted" : "Not accepted" }
      row.action(
        href: data_sharing_agreement_organisation_path(organisation),
        text: "View agreement",
      )
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
end
