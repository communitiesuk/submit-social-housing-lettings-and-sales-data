require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyLength, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancylength")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the length of the fixed-term tenancy to the nearest year?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Length of fixed-term tenancy")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("Don’t include the starter or introductory period.")
  end

  it "has the correct minimum and maximum" do
    expect(question.min).to eq 0
    expect(question.max).to eq 150
  end

  it "has the correct step" do
    expect(question.step).to eq 1
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end
