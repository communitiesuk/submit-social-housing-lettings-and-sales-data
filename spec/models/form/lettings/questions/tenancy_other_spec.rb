require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyOther, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancyother")
  end

  it "has the correct header" do
    expect(question.header).to eq("Please state the tenancy type")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end
