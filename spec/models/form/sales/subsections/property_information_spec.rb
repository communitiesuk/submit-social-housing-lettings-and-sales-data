require "rails_helper"

RSpec.describe Form::Sales::Subsections::PropertyInformation, type: :model do
  subject(:property_information) { described_class.new(nil, nil, section) }

  let(:section) { instance_double(Form::Sales::Sections::PropertyInformation) }

  it "has correct section" do
    expect(property_information.section).to eq(section)
  end

  describe "pages" do
    let(:section) { instance_double(Form::Sales::Sections::Household, form:) }
    let(:form) { instance_double(Form, start_date:) }

    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    context "when 2023" do
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "has correct pages" do
        expect(property_information.pages.map(&:id)).to eq(
          %w[
            property_number_of_bedrooms
            about_price_bedrooms_value_check
            property_unit_type
            monthly_charges_property_type_value_check
            percentage_discount_proptype_value_check
            property_building_type
            uprn
            uprn_confirmation
            address
            property_local_authority
            local_authority_buyer_1_income_max_value_check
            local_authority_buyer_2_income_max_value_check
            local_authority_combined_income_max_value_check
            about_price_la_value_check
            property_wheelchair_accessible
          ],
        )
      end
    end

    context "when 2024" do
      let(:start_date) { Time.utc(2024, 2, 8) }

      before do
        allow(form).to receive(:start_year_after_2024?).and_return(true)
      end

      it "has correct pages" do
        expect(property_information.pages.map(&:id)).to eq(
          %w[
            uprn
            uprn_confirmation
            address_matcher
            no_address_found
            uprn_selection
            address
            property_local_authority
            local_authority_buyer_1_income_max_value_check
            local_authority_buyer_2_income_max_value_check
            local_authority_combined_income_max_value_check
            about_price_la_value_check
            property_number_of_bedrooms
            about_price_bedrooms_value_check
            property_unit_type
            monthly_charges_property_type_value_check
            percentage_discount_proptype_value_check
            property_building_type
            property_wheelchair_accessible
          ],
        )
      end
    end
  end

  it "has the correct id" do
    expect(property_information.id).to eq("property_information")
  end

  it "has the correct label" do
    expect(property_information.label).to eq("Property information")
  end
end
