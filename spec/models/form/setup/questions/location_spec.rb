require "rails_helper"

RSpec.describe Form::Setup::Questions::Location, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("location")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which location used by #{scheme.service_name} is this log for?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Location")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is marked as derived" do
    expect(question.derived?).to be_falsey
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({})
  end
end
