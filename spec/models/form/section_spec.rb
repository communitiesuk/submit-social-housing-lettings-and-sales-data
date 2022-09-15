require "rails_helper"

RSpec.describe Form::Section, type: :model do
  subject(:section) { described_class.new(section_id, section_definition, form) }

  let(:lettings_log) { FactoryBot.build(:lettings_log) }
  let(:form) { lettings_log.form }
  let(:section_id) { "household" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  it "has an id" do
    expect(section.id).to eq(section_id)
  end

  it "has a label" do
    expect(section.label).to eq("About the household")
  end

  it "has a description" do
    expect(section.description).to eq("Make sure the tenant has seen the privacy notice.")
  end

  it "has subsections" do
    expected_subsections = %w[household_characteristics household_needs]
    expect(section.subsections.map(&:id)).to eq(expected_subsections)
  end
end
