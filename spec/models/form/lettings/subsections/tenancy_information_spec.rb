require "rails_helper"

RSpec.describe Form::Lettings::Subsections::TenancyInformation, type: :model do
  subject(:tenancy_information) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::TenancyAndProperty) }

  it "has correct section" do
    expect(tenancy_information.section).to eq(section)
  end

  describe "pages" do
    let(:section) { instance_double(Form::Sales::Sections::TenancyInformation, form:) }
    let(:form) { instance_double(Form, start_date:) }

    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    context "when 2023" do
      let(:start_date) { Time.utc(2023, 2, 8) }

      it "has correct pages" do
        expect(tenancy_information.pages.map(&:id)).to eq(
          %w[joint starter_tenancy tenancy_type starter_tenancy_type tenancy_length tenancy_length_affordable_rent tenancy_length_intermediate_rent sheltered_accommodation],
        )
      end
    end

    context "when 2024" do
      let(:start_date) { Time.utc(2024, 2, 8) }

      before do
        allow(form).to receive(:start_year_after_2024?).and_return(true)
      end

      it "has correct pages" do
        expect(tenancy_information.pages.map(&:id)).to eq(
          %w[joint starter_tenancy tenancy_type starter_tenancy_type tenancy_length tenancy_length_affordable_rent tenancy_length_intermediate_rent tenancy_length_periodic sheltered_accommodation],
        )
      end
    end
  end

  it "has the correct id" do
    expect(tenancy_information.id).to eq("tenancy_information")
  end

  it "has the correct label" do
    expect(tenancy_information.label).to eq("Tenancy information")
  end

  it "has the correct depends_on" do
    expect(tenancy_information.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end
