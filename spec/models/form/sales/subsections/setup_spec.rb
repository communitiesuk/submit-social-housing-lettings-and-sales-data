require "rails_helper"

RSpec.describe Form::Sales::Subsections::Setup, type: :model do
  subject(:setup) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Setup, form: instance_double(Form, start_date:)) }
  let(:start_date) { Time.utc(2022, 4, 1) }

  it "has correct section" do
    expect(setup.section).to eq(section)
  end

  it "has the correct id" do
    expect(setup.id).to eq("setup")
  end

  it "has the correct label" do
    expect(setup.label).to eq("Set up this sales log")
  end

  context "when start year is before 2024" do
    before do
      allow(section.form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has correct pages" do
      expect(setup.pages.map(&:id)).to eq(
        %w[
          completion_date
          owning_organisation
          managing_organisation
          assigned_to
          purchaser_code
          ownership_scheme
          shared_ownership_type
          discounted_ownership_type
          outright_ownership_type
          buyer_company
          buyer_live
          joint_purchase
          number_joint_buyers
        ],
      )
    end
  end

  context "when start year is >= 2024" do
    before do
      allow(section.form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has correct pages" do
      expect(setup.pages.map(&:id)).to eq(
        %w[
          completion_date
          owning_organisation
          managing_organisation
          assigned_to
          purchaser_code
          ownership_scheme
          shared_ownership_type
          discounted_ownership_type
          outright_ownership_type
          buyer_company
          buyer_live
          joint_purchase
          number_joint_buyers
          buyer_interview_joint_purchase
          buyer_interview
          privacy_notice_joint_purchase
          privacy_notice
        ],
      )
    end
  end
end
