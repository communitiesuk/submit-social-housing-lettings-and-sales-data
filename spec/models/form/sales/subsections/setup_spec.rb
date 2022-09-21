require "rails_helper"

RSpec.describe Form::Sales::Subsections::Setup, type: :model do
  subject(:setup) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Setup) }

  it "has correct section" do
    expect(setup.section).to eq(section)
  end

  it "has correct pages" do
    expect(setup.pages.map(&:id)).to eq(
      %w[organisation created_by completion_date purchaser_code ownership_scheme shared_ownership_type discounted_ownership_type joint_purchase],
    )
  end

  it "has the correct id" do
    expect(setup.id).to eq("setup")
  end

  it "has the correct label" do
    expect(setup.label).to eq("Set up this sales log")
  end
end
