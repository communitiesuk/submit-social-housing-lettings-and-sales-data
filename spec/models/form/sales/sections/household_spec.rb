require "rails_helper"

RSpec.describe Form::Sales::Sections::Household, type: :model do
  subject(:household) { described_class.new(section_id, section_definition, form) }

  let(:section_id) { nil }
  let(:section_definition) { nil }
  let(:form) { instance_double(Form) }

  it "has correct form" do
    expect(household.form).to eq(form)
  end

  it "has correct subsections" do
    expect(household.subsections.map(&:id)).to eq(
      %w[
        household_characteristics
        household_situation
        household_needs
      ],
    )
  end

  it "has the correct id" do
    expect(household.id).to eq("household")
  end

  it "has the correct label" do
    expect(household.label).to eq("About the household")
  end

  it "has the correct description" do
    expect(household.description).to eq("")
  end
end
