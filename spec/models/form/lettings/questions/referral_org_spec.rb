require "rails_helper"

RSpec.describe Form::Lettings::Questions::ReferralOrg, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, referral_noms) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:referral_noms) { nil }
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
    expect(question.id).to eq("referral_org")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "when referral_noms is 1" do
    let(:referral_noms) { 1 }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq(
        {
          "1" => {
            "value" => "Referred to LA by health service",
          },
          "2" => {
            "value" => "Referred to LA by community learning disability team",
          },
          "3" => {
            "value" => "Referred to LA by community mental health team",
          },
          "4" => {
            "value" => "Referred to LA by adult social services",
          },
          "5" => {
            "value" => "Referred to LA by children's social care",
          },
          "6" => {
            "value" => "Referred to LA by police, probation, prison or youth offending team following a custodial sentence",
          },
          "7" => {
            "value" => "Referred to LA by police, probation, prison or youth offending team without a custodial sentence",
          },
          "8" => {
            "value" => "Referred to LA by a voluntary agency",
          },
          "9" => {
            "value" => "Other referral",
          },
          "10" => {
            "value" => "Don't know",
          },
        }.freeze,
      )
    end
  end

  context "when referral_noms is 7" do
    let(:referral_noms) { 7 }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq(
        {
          "11" => {
            "value" => "Health service",
          },
          "12" => {
            "value" => "Community learning disability team",
          },
          "13" => {
            "value" => "Community mental health team",
          },
          "14" => {
            "value" => "Adult social services",
          },
          "15" => {
            "value" => "Children's social care",
          },
          "16" => {
            "value" => "Police, probation, prison or youth offending team following a custodial sentence",
          },
          "17" => {
            "value" => "Police, probation, prison or youth offending team without a custodial sentence",
          },
          "18" => {
            "value" => "Voluntary agency",
          },
          "19" => {
            "value" => "Other third party",
          },
          "20" => {
            "value" => "Don't know",
          },
        }.freeze,
      )
    end
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(92)
  end
end
