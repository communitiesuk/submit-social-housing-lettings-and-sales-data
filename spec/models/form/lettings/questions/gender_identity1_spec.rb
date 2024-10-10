require "rails_helper"

RSpec.describe Form::Lettings::Questions::GenderIdentity1, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page) }

  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_after_2024?: false) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has the correct id" do
    expect(question.id).to eq("sex1")
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "F" => { "value" => "Female" },
      "M" => { "value" => "Male" },
      "X" => { "value" => "Non-binary" },
      "divider" => { "value" => true },
      "R" => { "value" => "Tenant prefers not to say" },
    })
  end
end
