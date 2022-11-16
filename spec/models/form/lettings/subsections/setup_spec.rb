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
        housing_provider
        managing_organisation
        created_by
        needs_type
        scheme
        location
        renewal
        tenancy_start_date
        rent_type
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
          housing_provider
          managing_organisation
          created_by
          needs_type
          scheme
          location
          renewal
          tenancy_start_date
          rent_type
          tenant_code
          property_reference
        ],
      )
    end
  end

  context "when production" do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    it "has the correct pages" do
      expect(setup.pages.map(&:id)).to eq(
        %w[
          organisation
          created_by
          needs_type
          scheme
          location
          renewal
          tenancy_start_date
          rent_type
          tenant_code
          property_reference
        ],
      )
    end
  end
end
