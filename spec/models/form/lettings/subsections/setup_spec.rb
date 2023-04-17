require "rails_helper"

RSpec.describe Form::Lettings::Subsections::Setup, type: :model do
  subject(:setup) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::Setup) }

  it "has correct section" do
    expect(setup.section).to eq(section)
  end

  it "has correct pages" do
    expect(setup.pages.map(&:id)).to eq(
      %w[
        stock_owner
        stock_owner_min_rent_value_check
        stock_owner_max_rent_value_check
        managing_organisation
        created_by
        needs_type
        scheme
        location
        needs_type_min_rent_value_check
        needs_type_max_rent_value_check
        renewal
        tenancy_start_date
        start_date_min_rent_value_check
        start_date_max_rent_value_check
        rent_type
        rent_type_min_rent_value_check
        rent_type_max_rent_value_check
        tenant_code
        property_reference
      ],
    )
  end

  it "has the correct id" do
    expect(setup.id).to eq("setup")
  end

  it "has the correct label" do
    expect(setup.label).to eq("Set up this lettings log")
  end

  context "when not production" do
    it "has correct pages" do
      expect(setup.pages.map(&:id)).to eq(
        %w[
          stock_owner
          stock_owner_min_rent_value_check
          stock_owner_max_rent_value_check
          managing_organisation
          created_by
          needs_type
          scheme
          location
          needs_type_min_rent_value_check
          needs_type_max_rent_value_check
          renewal
          tenancy_start_date
          start_date_min_rent_value_check
          start_date_max_rent_value_check
          rent_type
          rent_type_min_rent_value_check
          rent_type_max_rent_value_check
          tenant_code
          property_reference
        ],
      )
    end
  end
end
