require "rails_helper"

RSpec.describe Form::Sales::Sections::Finances, type: :model do
  subject(:section) { described_class.new(section_id, section_definition, form) }

  let(:section_id) { nil }
  let(:section_definition) { nil }
  let(:form) { instance_double(Form) }

  it "has correct form" do
    expect(section.form).to eq(form)
  end

  it "has correct subsections" do
    expect(section.subsections.map(&:id)).to eq(
      %w[
        income_benefits_and_savings
      ],
    )
  end

  it "has the correct id" do
    expect(section.id).to eq("finances")
  end

  it "has the correct label" do
    expect(section.label).to eq("Finances")
  end

  it "has the correct description" do
    expect(section.description).to eq("")
  end
end
