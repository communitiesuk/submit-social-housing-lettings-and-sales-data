class MergeRequestOrganisation < ApplicationRecord
  belongs_to :merge_request, class_name: "MergeRequest"
  belongs_to :merging_organisation, class_name: "Organisation"
  validates :merge_request_id, presence: { message: I18n.t("validations.organisation.stock_owner.blank") }
  validates :merging_organisation_id, presence: { message: I18n.t("validations.organisation.managing_agent.blank") }

  has_paper_trail
end
