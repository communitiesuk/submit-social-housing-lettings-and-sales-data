require "rails_helper"

RSpec.describe Form::Lettings::Subsections::HouseholdSituation, type: :model do
  subject(:household_situation) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::Household) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }

  before do
    allow(section).to receive(:form).and_return(form)
    allow(form).to receive(:start_year_2024_or_later?).and_return(false)
    allow(form).to receive(:start_year_2025_or_later?).and_return(false)
    allow(form).to receive(:start_year_2026_or_later?).and_return(false)
  end

  it "has correct section" do
    expect(household_situation.section).to eq(section)
  end

  context "with form year is 2024", metadata: { year: 24 } do
    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has correct pages" do
      expect(household_situation.pages.map(&:id)).to eq(
        %w[
          time_lived_in_local_authority
          time_on_waiting_list
          reason_for_leaving_last_settled_home
          reason_for_leaving_last_settled_home_renewal
          reasonother_value_check
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
          referral_value_check
        ],
      )
    end
  end

  context "with form year is 2025", metadata: { year: 25 } do
    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "has correct pages" do
      expect(household_situation.pages.map(&:id)).to eq(
        %w[
          time_lived_in_local_authority
          time_on_waiting_list
          reason_for_leaving_last_settled_home
          reason_for_leaving_last_settled_home_renewal
          reasonother_value_check
          previous_housing_situation
          previous_housing_situation_renewal
          homelessness
          previous_postcode
          previous_local_authority
          reasonable_preference
          reasonable_preference_reason
          allocation_system
          referral_type
          referral_direct
          referral_la
          referral_prp
          referral_hsc
          referral_justice
          referral_value_check
        ],
      )
    end
  end

  context "with form year is 2026", metadata: { year: 26 } do
    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
      allow(form).to receive(:start_year_2026_or_later?).and_return(true)
    end

    it "has correct pages" do
      expect(household_situation.pages.map(&:id)).to eq(
        %w[
          time_lived_in_local_authority
          time_on_waiting_list
          reason_for_leaving_last_settled_home
          reason_for_leaving_last_settled_home_renewal
          reasonother_value_check
          previous_housing_situation
          previous_housing_situation_renewal
          homelessness
          previous_postcode
          previous_local_authority
          reasonable_preference
          reasonable_preference_reason
          allocation_system
          referral_register_la
          referral_register_prp
          referral_noms_la_hr
          referral_noms_hr
          referral_org_nominated
          referral_org_directly_referred
        ],
      )
    end
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
