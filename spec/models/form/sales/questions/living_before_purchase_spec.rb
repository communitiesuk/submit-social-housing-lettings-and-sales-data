require "rails_helper"

RSpec.describe Form::Sales::Questions::LivingBeforePurchase, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("proplen")
  end

  it "has the correct header" do
    expect(question.header).to eq("How long did the buyer(s) live in the property before purchase?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Number of years buyers living in the property before purchase")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("You should round this up to the nearest year. If the buyers haven't been living in the property, enter '0'")
  end

  it "has correct width" do
    expect(question.width).to eq(5)
  end

  it "has correct step" do
    expect(question.step).to eq(1)
  end

  it "has correct suffix" do
    expect(question.suffix).to eq(" years")
  end

  it "has correct min" do
    expect(question.min).to eq(0)
  end

  it "has correct max" do
    expect(question.max).to eq(80)
  end
end
