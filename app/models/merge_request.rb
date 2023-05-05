class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
  has_many :merge_request_organisations
  belongs_to :absorbing_organisation, class_name: "Organisation", optional: true
  has_many :merging_organisations, through: :merge_request_organisations, source: :merging_organisation
  validate :organisation_name_uniqueness, if: :new_organisation_name
  validates :new_telephone_number, presence: true, if: -> { telephone_number_correct == false }

  STATUS = {
    "unsubmitted" => 0,
    "submitted" => 1,
  }.freeze
  enum status: STATUS

  def organisation_name_uniqueness
    if Organisation.where("lower(name) = ?", new_organisation_name&.downcase).exists?
      errors.add(:new_organisation_name, :invalid)
    end
  end
end
