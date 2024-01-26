require "rails_helper"

RSpec.describe Form::Sales::Questions::JointPurchase, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("jointpur")
  end

  it "has the correct header" do
    expect(question.header).to eq("Is this a joint purchase?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Joint purchase")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    })
  end

  context "with collection year before 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has the blank hint_text" do
      expect(question.hint_text).to be_nil
    end
  end

  context "with collection year >= 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct hint_text" do
      expect(question.hint_text).to eq("This is where two or more people are named as legal owners of the property after the purchase")
    end
  end
end
