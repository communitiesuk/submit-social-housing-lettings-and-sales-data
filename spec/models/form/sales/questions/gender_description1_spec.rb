require "rails_helper"

RSpec.describe Form::Sales::Questions::GenderDescription1, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2026, 4, 1)) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("gender_description1")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "has expected check answers card number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to be_nil
  end

  context "when gender_same_as_sex1 is 'Yes'" do
    let(:log) { build(:sales_log, gender_same_as_sex1: 1) }

    it "is marked as derived" do
      expect(question.derived?(log)).to be true
    end
  end

  context "when gender_same_as_sex1 is 'No'" do
    let(:log) { build(:sales_log, gender_same_as_sex1: 2) }

    it "is not marked as derived" do
      expect(question.derived?(log)).to be false
    end
  end

  context "when gender_same_as_sex1 is 'Prefers not to say'" do
    let(:log) { build(:sales_log, gender_same_as_sex1: 3) }

    it "is marked as derived" do
      expect(question.derived?(log)).to be true
    end
  end
end
