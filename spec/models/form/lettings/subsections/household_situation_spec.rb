require "rails_helper"

RSpec.describe Form::Lettings::Subsections::HouseholdSituation, type: :model do
  subject(:household_situation) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::Household) }

  it "has correct section" do
    expect(household_situation.section).to eq(section)
  end

  it "has correct pages" do
    expect(household_situation.pages.map(&:id)).to eq(
      %w[
        time_lived_in_local_authority
        time_on_waiting_list
        reason_for_leaving_last_settled_home
        reason_for_leaving_last_settled_home_renewal
        previous_housing_situation
        previous_housing_situation_renewal
        homelessness
        previous_postcode
        previous_local_authority
        reasonable_preference
        reasonable_preference_reason
        allocation_system
        referral
        referral_prp
        referral_supported_housing
        referral_supported_housing_prp
      ],
    )
  end

  it "has the correct id" do
    expect(household_situation.id).to eq("household_situation")
  end

  it "has the correct label" do
    expect(household_situation.label).to eq("Household situation")
  end

  it "has the correct depends_on" do
    expect(household_situation.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end
