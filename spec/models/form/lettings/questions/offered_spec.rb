require "rails_helper"

RSpec.describe Form::Lettings::Questions::Offered, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to be page
  end

  it "has the correct id" do
    expect(question.id).to eq "offered"
  end

  it "has the correct header" do
    expect(question.header).to eq "How many times was the property offered between becoming vacant and this letting?"
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq "Times previously offered since becoming available"
  end

  it "has the correct type" do
    expect(question.type).to eq "numeric"
  end

  it "has the correct minimum and maximum values" do
    expect(question.min).to be 0
    expect(question.max).to be 150
  end

  it "has the correct step" do
    expect(question.step).to be 1
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq "Do not include the offer that led to this letting. This is after the last tenancy ended. If the property is being offered for let for the first time, enter 0."
  end
end
