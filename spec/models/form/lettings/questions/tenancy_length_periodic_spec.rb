require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyLengthPeriodic, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancylength")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the length of the periodic tenancy to the nearest year?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Length of periodic tenancy")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("As this is a periodic tenancy, this question is optional. If you do not have the information available click save and continue")
  end
end
