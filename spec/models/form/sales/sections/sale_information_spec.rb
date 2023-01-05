require "rails_helper"

RSpec.describe Form::Sales::Sections::SaleInformation, type: :model do
  subject(:sale_information) { described_class.new(section_id, section_definition, form) }

  let(:section_id) { nil }
  let(:section_definition) { nil }
  let(:form) { instance_double(Form) }

  it "has correct form" do
    expect(sale_information.form).to eq(form)
  end

  it "has correct subsections" do
    expect(sale_information.subsections.map(&:id)).to eq(%w[
      shared_ownership_scheme
      discounted_ownership_scheme
      outright_sale
    ])
  end

  it "has the correct id" do
    expect(sale_information.id).to eq("sale_information")
  end

  it "has the correct label" do
    expect(sale_information.label).to eq("Sale information")
  end

  it "has the correct description" do
    expect(sale_information.description).to eq("")
  end
end
