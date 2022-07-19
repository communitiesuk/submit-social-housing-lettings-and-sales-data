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
  let(:case_log) { FactoryBot.create(:case_log) }
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
    expect(question.header).to eq("Which organisation owns this log?")
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

    it "is shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, support_user)).to be false
    end
  end

  context "when the current user is not support" do
    let(:user) { FactoryBot.build(:user) }

    it "is not shown in check answers" do
      expect(question.hidden_in_check_answers?(nil, user)).to be true
    end
  end

  context "when the question is not answered" do
    it "returns 'select an option' as selected answer" do
      case_log.update!(owning_organisation: nil)
      answers = question.displayed_answer_options(case_log).map { |key, value| OpenStruct.new(id: key, name: nil, resource: value) }
      answers.each do |answer|
        if answer.resource == "Select an option"
          expect(question.answer_selected?(case_log, answer)).to eq(true)
        else
          expect(question.answer_selected?(case_log, answer)).to eq(false)
        end
      end
    end
  end

  context "when the question is answered" do
    it "returns 'select an option' as selected answer" do
      case_log.update!(owning_organisation: organisation_1)
      answers = question.displayed_answer_options(case_log).map { |key, value| OpenStruct.new(id: key, name: value.respond_to?(:service_name) ? value.service_name : nil, resource: value) }
      answers.each do |answer|
        if answer.id == organisation_1.id
          expect(question.answer_selected?(case_log, answer)).to eq(true)
        else
          expect(question.answer_selected?(case_log, answer)).to eq(false)
        end
      end
    end
  end
end
