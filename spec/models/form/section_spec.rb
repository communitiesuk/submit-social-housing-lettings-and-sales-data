require "rails_helper"

RSpec.describe Form::Section, type: :model do
  let(:form) { FormHandler.instance.get_form("test_form") }
  let(:section_id) { "household" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  subject { Form::Section.new(section_id, section_definition, form) }

  it "has an id" do
    expect(subject.id).to eq(section_id)
  end

  it "has a label" do
    expect(subject.label).to eq("About the household")
  end

  it "has subsections" do
    expected_subsections = %w[household_characteristics household_needs]
    expect(subject.subsections.map(&:id)).to eq(expected_subsections)
  end
end
