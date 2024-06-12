class OrganisationRentPeriod < ApplicationRecord
  belongs_to :organisation

  validates :organisation_id, uniqueness: { scope: :rent_period } # rubocop:disable Rails/UniqueValidationWithoutIndex

  has_paper_trail
end
