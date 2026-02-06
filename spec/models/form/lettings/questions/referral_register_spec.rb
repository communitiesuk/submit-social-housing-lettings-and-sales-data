require "rails_helper"

RSpec.describe Form::Lettings::Questions::ReferralRegister, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, provider_type) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:provider_type) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.today) }
  let(:is_renewal?) { nil }
  let(:log) { instance_double(LettingsLog, is_renewal?: is_renewal?) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("referral_register")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  context "when log is a renewal" do
    let(:is_renewal?) { true }

    it "is marked as derived" do
      expect(question.derived?(log)).to be true
    end
  end

  context "when log is not a renewal" do
    let(:is_renewal?) { false }

    it "is not marked as derived" do
      expect(question.derived?(log)).to be false
    end
  end

  context "when log is owned by an LA" do
    let(:provider_type) { :la }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq(
        {
          "1" => {
            "value" => "Renewal to the same tenant in the same property",
          },
          "2" => {
            "value" => "Internal transfer from another property owned by the same local authority - for existing social tenants only",
          },
          "3" => {
            "value" => "From a housing register (waiting list)",
          },
          "4" => {
            "value" => "Tenant applied directly (not via a nomination or housing register)",
          },
        }.freeze,
      )
    end
  end

  context "when log is owned by an PRP" do
    let(:provider_type) { :prp }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq(
        {
          "1" => {
            "value" => "Answer A",
          },
          "2" => {
            "value" => "Answer B",
          },
        }.freeze,
      )
    end
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(84)
  end
end
