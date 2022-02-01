require "rails_helper"

RSpec.describe Form::Section, type: :model do
  subject(:section) { described_class.new(section_id, section_definition, form) }

  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
  let(:section_id) { "household" }
  let(:section_definition) { form.form_definition["sections"][section_id] }

  it "has an id" do
    expect(section.id).to eq(section_id)
  end

  it "has a label" do
    expect(section.label).to eq("About the household")
  end

  it "has subsections" do
    expected_subsections = %w[household_characteristics household_needs]
    expect(section.subsections.map(&:id)).to eq(expected_subsections)
  end
end
