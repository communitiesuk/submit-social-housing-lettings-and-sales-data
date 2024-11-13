require "rails_helper"

RSpec.describe Form::Lettings::Questions::Rsnvac, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_2024_or_later?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("rsnvac")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "13" => {
          "value" => "Internal transfer",
          "hint" => "Where a tenant moved from one social housing property to another property. Their landlord may be the same or may have changed.",
        },
        "5" => {
          "value" => "Previous tenant died with no succession",
        },
        "9" => {
          "value" => "Re-let to tenant who occupied same property as temporary accommodation",
        },
        "14" => {
          "value" => "Renewal of fixed-term tenancy",
          "hint" => "To the same tenant in the same property, except if was previously used as temporary accommodation.",
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
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "14" => {
          "value" => "Renewal of fixed-term tenancy",
          "hint" => "To the same tenant in the same property, except if was previously used as temporary accommodation.",
        },
        "9" => {
          "value" => "Re-let to tenant who occupied same property as temporary accommodation",
        },
        "13" => {
          "value" => "Internal transfer",
          "hint" => "Where a tenant moved from one social housing property to another property. Their landlord may be the same or may have changed.",
        },
        "12" => {
          "value" => "Tenant moved to other social housing provider",
        },
        "8" => {
          "value" => "Tenant moved to private sector or other accommodation",
        },
        "18" => {
          "value" => "Tenant moved to care home",
        },
        "20" => {
          "value" => "Tenant moved to long-stay hospital or similar institution",
        },
        "5" => {
          "value" => "Tenant died with no succession",
        },
        "19" => {
          "value" => "Tenant involved in a succession downsize",
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
        "21" => {
          "value" => "Tenant was evicted due to both rent arrears and anti-social behaviour",
        },
        "22" => {
          "value" => "Any other reason",
        },
      })
    end
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end
end
