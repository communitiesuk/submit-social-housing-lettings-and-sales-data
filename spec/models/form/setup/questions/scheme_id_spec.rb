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
    let(:user) { FactoryBot.create(:user, organisation:) }
    let(:scheme) { FactoryBot.create(:scheme, owning_organisation: organisation) }
    let(:case_log) { FactoryBot.create(:case_log, created_by: user, needstype: 2) }

    before do
      FactoryBot.create(:scheme, owning_organisation: organisation_2)
    end

    context "when a scheme with at least 1 location exists" do
      before do
        FactoryBot.create(:location, scheme:)
      end

      it "has the correct answer_options based on the schemes the user's organisation owns or manages" do
        expected_answer = { "" => "Select an option", scheme.id.to_s => scheme }
        expect(question.displayed_answer_options(case_log)).to eq(expected_answer)
      end
    end

    context "when there are no schemes with locations" do
      it "returns a hash with one empty option" do
        expect(question.displayed_answer_options(case_log)).to eq({ "" => "Select an option" })
      end
    end

    context "when the question is not answered" do
      it "returns 'select an option' as selected answer" do
        case_log.update!(scheme: nil)
        answers = question.displayed_answer_options(case_log).map { |key, value| OpenStruct.new(id: key, name: value.respond_to?(:service_name) ? value.service_name : nil, resource: value) }
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
        case_log.update!(scheme:)
        answers = question.displayed_answer_options(case_log).map { |key, value| OpenStruct.new(id: key, name: value.respond_to?(:service_name) ? value.service_name : nil, resource: value) }
        answers.each do |answer|
          if answer.id == scheme.id
            expect(question.answer_selected?(case_log, answer)).to eq(true)
          else
            expect(question.answer_selected?(case_log, answer)).to eq(false)
          end
        end
      end
    end
  end
end
