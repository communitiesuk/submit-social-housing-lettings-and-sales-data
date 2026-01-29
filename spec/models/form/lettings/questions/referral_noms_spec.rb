require "rails_helper"

RSpec.describe Form::Lettings::Questions::ReferralNoms, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, referral_register) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:referral_register) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.today) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("referral_noms")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "when referral_register is 6" do
    let(:referral_register) { 6 }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq(
        {
          "1" => {
            "value" => "Nominated by a local authority to a PRP",
          },
          "2" => {
            "value" => "Supported housing only - referred by a local authority to a PRP",
          },
          "3" => {
            "value" => "Internal transfer from another property owned by the same PRP landlord - for existing social tenants only",
          },
          "4" => {
            "value" => "Other",
          },
        }.freeze,
      )
    end
  end

  context "when referral_register is 7" do
    let(:referral_register) { 7 }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq(
        {
          "5" => {
            "value" => "Internal transfer from another property owned by the same PRP landlord - for existing social tenants only",
          },
          "6" => {
            "value" => " A different PRP landlord - for existing socail tenants only",
          },
          "7" => {
            "value" => "Directly referred by a third party",
          },
          "8" => {
            "value" => "Other",
          },
        }.freeze,
      )
    end
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(84)
  end
end
