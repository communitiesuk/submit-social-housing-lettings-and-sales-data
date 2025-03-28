require "rails_helper"

RSpec.describe Form::Sales::Questions::ArmedForcesSpouse, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("armedforcesspouse")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "4" => { "value" => "Yes" },
      "5" => { "value" => "No" },
      "6" => { "value" => "Buyer prefers not to say" },
      "divider" => { "value" => true },
      "7" => { "value" => "Don’t know" },
    })
  end
end
