require "rails_helper"

RSpec.describe Form::Lettings::Questions::AddressLine1, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("address_line1")
  end

  it "has the correct header" do
    expect(question.header).to eq("Address line 1")
  end

  it "has the correct question_number" do
    expect(question.question_number).to be_nil
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Q12 - Address")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  it "has the correct inferred check answers value" do
    expect(question.inferred_check_answers_value).to be_nil
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to be_nil
  end

  describe "has the correct get_extra_check_answer_value" do
    context "when la is not present" do
      let(:log) { create(:lettings_log, la: nil) }

      it "returns nil" do
        expect(question.get_extra_check_answer_value(log)).to be_nil
      end
    end

    context "when la is present but not inferred" do
      let(:log) { create(:lettings_log, la: "E09000003", is_la_inferred: false) }

      it "returns nil" do
        expect(question.get_extra_check_answer_value(log)).to be_nil
      end
    end

    context "when la is present and inferred" do
      let(:log) { create(:lettings_log, la: "E09000003") }

      before do
        allow(log).to receive(:is_la_inferred?).and_return(true)
      end

      it "returns the la" do
        expect(question.get_extra_check_answer_value(log)).to eq("Barnet")
      end
    end
  end
end
