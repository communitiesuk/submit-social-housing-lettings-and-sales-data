require "rails_helper"

RSpec.describe Form::Lettings::Questions::Rsnvac, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("rsnvac")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the reason for the property being vacant?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Vacancy reason")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "13" => {
        "value" => "Internal transfer",
        "hint" => "Excluding renewals of a fixed-term tenancy",
      },
      "5" => {
        "value" => "Previous tenant died with no succession",
      },
      "9" => {
        "value" => "Re-let to tenant who occupied same property as temporary accommodation",
      },
      "14" => {
        "value" => "Renewal of fixed-term tenancy",
      },
      "19" => {
        "value" => "Tenant involved in a succession downsize",
      },
      "8" => {
        "value" => "Tenant moved to private sector or other accommodation",
      },
      "12" => {
        "value" => "Tenant moved to other social housing provider",
      },
      "18" => {
        "value" => "Tenant moved to care home",
      },
      "20" => {
        "value" => "Tenant moved to long-stay hospital or similar institution",
      },
      "6" => {
        "value" => "Tenant abandoned property",
      },
      "10" => {
        "value" => "Tenant was evicted due to rent arrears",
      },
      "11" => {
        "value" => "Tenant was evicted due to anti-social behaviour",
      },
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end
end
