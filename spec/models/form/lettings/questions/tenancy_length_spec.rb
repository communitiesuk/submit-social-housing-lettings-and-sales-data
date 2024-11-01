require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyLength, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))), id: "tenancy_length") }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancylength")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "has the correct minimum and maximum" do
    expect(question.min).to eq 0
    expect(question.max).to eq 150
  end

  it "has the correct step" do
    expect(question.step).to eq 1
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end
end
