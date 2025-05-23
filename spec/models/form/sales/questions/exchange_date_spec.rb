require "rails_helper"

RSpec.describe Form::Sales::Questions::ExchangeDate, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("exdate")
  end

  it "has the correct type" do
    expect(question.type).to eq("date")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end
end
