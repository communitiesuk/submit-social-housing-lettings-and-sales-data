require "rails_helper"

RSpec.describe Form::Setup::Questions::SchemeId, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("scheme_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("What scheme is this log for?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Scheme name")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("Enter scheme name or postcode")
  end

  it "has the correct conditional_for" do
    expect(question.conditional_for).to be_nil
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  context "when a user is signed in" do
    let(:organisation) { FactoryBot.create(:organisation) }
    let(:organisation_2) { FactoryBot.create(:organisation) }
    let(:user) { FactoryBot.create(:user, organisation_id: organisation.id) }
    let(:scheme) { FactoryBot.create(:scheme, organisation_id: organisation.id) }
    let(:case_log) { FactoryBot.create(:case_log, created_by: user) }

    before do
      FactoryBot.create(:scheme, organisation_id: organisation_2.id)
    end

    it "has the correct answer_options based on the schemes the user's organisation owns or manages" do
      expected_answer = { scheme.id.to_s => scheme.service_name }
      expect(question.displayed_answer_options(case_log)).to eq(expected_answer)
    end
  end
end
