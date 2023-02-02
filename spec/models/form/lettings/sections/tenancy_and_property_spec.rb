require "rails_helper"

RSpec.describe Form::Lettings::Sections::TenancyAndProperty, type: :model do
  subject(:tenancy_and_property) { described_class.new(section_id, section_definition, form) }

  let(:section_id) { nil }
  let(:section_definition) { nil }
  let(:form) { instance_double(Form) }

  it "has correct form" do
    expect(tenancy_and_property.form).to eq(form)
  end

  it "has correct subsections" do
    expect(tenancy_and_property.subsections.map(&:id)).to eq(%w[property_information tenancy_information])
  end

  it "has the correct id" do
    expect(tenancy_and_property.id).to eq("tenancy_and_property")
  end

  it "has the correct label" do
    expect(tenancy_and_property.label).to eq("Property and tenancy information")
  end

  it "has the correct description" do
    expect(tenancy_and_property.description).to be nil
  end
end
