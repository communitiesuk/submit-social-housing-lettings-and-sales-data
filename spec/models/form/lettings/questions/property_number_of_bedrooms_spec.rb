require "rails_helper"

RSpec.describe Form::Lettings::Questions::PropertyNumberOfBedrooms, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("beds")
  end

  it "has the correct header" do
    expect(question.header).to eq("How many bedrooms does the property have?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Number of bedrooms")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct min" do
    expect(question.min).to eq(1)
  end

  it "has the correct max" do
    expect(question.max).to eq(9)
  end

  context "with 2023/24 form" do
    it "has the correct hint_text" do
      expect(question.hint_text).to eq("If shared accommodation, enter the number of bedrooms occupied by this household. A bedsit has 1 bedroom.")
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct hint_text" do
      expect(question.hint_text).to eq("If shared accommodation, enter the number of bedrooms occupied by this household.")
    end
  end
end
