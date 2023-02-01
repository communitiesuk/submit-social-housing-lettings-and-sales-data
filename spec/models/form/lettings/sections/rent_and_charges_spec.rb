require "rails_helper"

RSpec.describe Form::Lettings::Sections::RentAndCharges, type: :model do
  subject(:rent_and_charges) { described_class.new(section_id, section_definition, form) }

  let(:section_id) { nil }
  let(:section_definition) { nil }
  let(:form) { instance_double(Form) }

  it "has correct form" do
    expect(rent_and_charges.form).to eq(form)
  end

  it "has correct subsections" do
    expect(rent_and_charges.subsections.map(&:id)).to eq(%w[income_and_benefits])
  end

  it "has the correct id" do
    expect(rent_and_charges.id).to eq("rent_and_charges")
  end

  it "has the correct label" do
    expect(rent_and_charges.label).to eq("Finances")
  end

  it "has the correct description" do
    expect(rent_and_charges.description).to be nil
  end
end
