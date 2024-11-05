require "rails_helper"

RSpec.describe Form::Sales::Questions::Discount, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(instance_double(Form, start_year_2024_or_later?: false, start_date: Time.zone.local(2023, 4, 1)))
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("discount")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has correct width" do
    expect(question.width).to eq(5)
  end

  it "has correct suffix" do
    expect(question.suffix).to eq("%")
  end

  it "has correct min" do
    expect(question.min).to eq(0)
  end

  it "has correct max" do
    expect(question.max).to eq(100)
  end

  context "with form start year after 2024" do
    before do
      allow(subsection).to receive(:form).and_return(instance_double(Form, start_year_2024_or_later?: true, start_date: Time.zone.local(2024, 4, 1)))
    end

    it "has correct max" do
      expect(question.max).to eq(70)
    end
  end
end
