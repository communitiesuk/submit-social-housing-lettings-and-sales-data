require "rails_helper"

RSpec.describe Form::Lettings::Questions::Reason, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("reason")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the tenant’s main reason for the household leaving their last settled home?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Reason for leaving last settled home")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("The tenant’s ‘last settled home’ is their last long-standing home. For tenants who were in temporary accommodation or sleeping rough, their last settled home is where they were living previously.")
  end

  it "has the correct conditional_for" do
    expect(question.conditional_for).to eq({ "reasonother" => [20] })
  end

  it "is not marked as derived" do
    expect(question).not_to be_derived
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "40" => {
        "value" => "End of assured shorthold tenancy (no fault)",
      },
      "41" => {
        "value" => "End of assured shorthold tenancy (eviction or tenant at fault)",
      },
      "42" => {
        "value" => "End of fixed term tenancy (no fault)",
      },
      "43" => {
        "value" => "End of fixed term tenancy (eviction or tenant at fault)",
      },
      "1" => {
        "value" => "Permanently decanted from another property owned by this landlord",
      },
      "46" => {
        "value" => "Discharged from long-stay hospital or similar institution",
      },
      "45" => {
        "value" => "Discharged from prison",
      },
      "2" => {
        "value" => "Left home country as a refugee",
      },
      "4" => {
        "value" => "Loss of tied accommodation",
      },
      "9" => {
        "value" => "Asked to leave by family or friends",
      },
      "44" => {
        "value" => "Death of household member in last settled accommodation",
      },
      "8" => {
        "value" => "Relationship breakdown (non-violent) with partner",
      },
      "16" => {
        "value" => "To move nearer to family, friends or school",
      },
      "17" => {
        "value" => "To move nearer to work",
      },
      "48" => {
        "value" => "Domestic abuse - previously joint tenancy with partner",
      },
      "49" => {
        "value" => "Domestic abuse - other",
      },
      "31" => {
        "value" => "Hate crime",
      },
      "10" => {
        "value" => "Racial harassment",
      },
      "11" => {
        "value" => "Other problems with neighbours",
      },
      "35" => {
        "value" => "Couldn’t afford fees attached to renewing the tenancy",
      },
      "36" => {
        "value" => "Couldn’t afford increase in rent",
      },
      "38" => {
        "value" => "Couldn’t afford rent or mortgage (employment)",
      },
      "37" => {
        "value" => "Couldn’t afford rent or mortgage (welfare reforms)",
      },
      "39" => {
        "value" => "Couldn’t afford rent or mortgage (other)",
      },
      "34" => {
        "value" => "Repossession",
      },
      "12" => {
        "value" => "Property unsuitable because of overcrowding",
      },
      "13" => {
        "value" => "Property unsuitable because of ill health or disability",
      },
      "14" => {
        "value" => "Property unsuitable because of poor condition",
      },
      "18" => {
        "value" => "To move to accommodation with support",
      },
      "19" => {
        "value" => "To move to independent accommodation",
      },
      "30" => {
        "value" => "Under occupation (no incentive)",
      },
      "29" => {
        "value" => "Under occupation (offered incentive to downsize)",
      },
      "20" => {
        "value" => "Other",
      },
      "47" => {
        "value" => "Tenant prefers not to say",
      },
      "divider" => {
        "value" => true,
      },
      "28" => {
        "value" => "Don’t know",
      },
    })
  end
end
