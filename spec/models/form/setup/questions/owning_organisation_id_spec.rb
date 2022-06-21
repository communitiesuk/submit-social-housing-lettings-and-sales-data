require "rails_helper"

RSpec.describe Form::Setup::Questions::OwningOrganisationId, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }
  let!(:organisation_1) { FactoryBot.create(:organisation, name: "first test org") }
  let!(:organisation_2) { FactoryBot.create(:organisation, name: "second test org") }
  let(:expected_answer_options) do
    {
      "" => "Select an option",
      organisation_1.id => organisation_1.name,
      organisation_2.id => organisation_2.name,
    }
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("owning_organisation_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which organisation is the owning organisation for this log?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Owning organisation")
  end

  it "has the correct type" do
    expect(question.type).to eq("select")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("")
  end

  it "has the correct answer options" do
    expect(question.answer_options).to eq(expected_answer_options)
  end

  it "is marked as derived" do
    expect(question.derived?).to be true
  end

  context "when the current user is support" do
    let(:support_user) { FactoryBot.build(:user, :support) }

    before do
      allow(page).to receive(:subsection).and_return(subsection)
      allow(subsection).to receive(:form).and_return(form)
      allow(form).to receive(:current_user).and_return(support_user)
    end

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers).to be false
    end
  end

  context "when the current user is not support" do
    let(:user) { FactoryBot.build(:user) }

    before do
      allow(page).to receive(:subsection).and_return(subsection)
      allow(subsection).to receive(:form).and_return(form)
      allow(form).to receive(:current_user).and_return(user)
    end

    it "is not shown in check answers" do
      expect(question.hidden_in_check_answers).to be true
    end
  end

  context "when the user is already set" do
    let(:user) { FactoryBot.create(:user, organisation: organisation_2) }
    let(:case_log) { FactoryBot.create(:case_log, created_by: user) }
    let(:expected_answer_options) do
      {
        "" => "Select an option",
        organisation_2.id => organisation_2.name,
      }
    end

    it "only displays users that belong to that organisation" do
      expect(question.displayed_answer_options(case_log)).to eq(expected_answer_options)
    end
  end
end
