require "rails_helper"

RSpec.describe Form::Lettings::Questions::AddressLine1, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: current_collection_start_date))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("address_line1")
  end

  it "has the correct error label" do
    expect(question.error_label).to eq("Address line 1")
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(17)
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct inferred check answers value" do
    expect(question.inferred_check_answers_value).to be_nil
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to be_nil
  end

  describe "#unanswered_error_message" do
    context "when the log is supported housing" do
      let(:log) { build(:lettings_log, needstype: 2) }

      it "returns the confidential-scheme guidance message" do
        expect(question.unanswered_error_message(log)).to eq(
          "You must enter address line 1. If your letting is in a confidential scheme, please check the scheme you chose in the ‘Set up this lettings log’ section. If a scheme needs updating to mark it as confidential, a CORE coordinator in your organisation can do this.",
        )
      end
    end

    context "when the log is general needs" do
      let(:log) { build(:lettings_log, needstype: 1) }

      it "returns the default unanswered message" do
        expect(question.unanswered_error_message(log)).to eq(
          I18n.t("validations.not_answered", question: question.error_display_label.downcase),
        )
      end
    end

    context "when no log is given" do
      it "returns the default unanswered message" do
        expect(question.unanswered_error_message).to eq(
          I18n.t("validations.not_answered", question: question.error_display_label.downcase),
        )
      end
    end
  end
end
