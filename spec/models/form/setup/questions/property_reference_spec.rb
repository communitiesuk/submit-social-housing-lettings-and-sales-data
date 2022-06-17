require "rails_helper"

RSpec.describe Form::Setup::Questions::PropertyReference, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("propcode")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the property reference?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Property reference")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("This is how you usually refer to this property on your own systems.")
  end

  it "has the correct width" do
    expect(question.width).to eq(10)
  end
end
