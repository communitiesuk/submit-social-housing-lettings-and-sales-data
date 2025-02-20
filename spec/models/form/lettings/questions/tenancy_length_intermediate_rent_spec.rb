require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyLengthIntermediateRent, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, id: "intermediate_tenancy_length") }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date:) }
  let(:start_date) { Time.utc(2023, 4, 1) }

  before do
    allow(form).to receive(:start_year_2024_or_later?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancylength")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  context "with 2024/25 form" do
    let(:start_date) { Time.utc(2024, 4, 1) }

    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(28)
    end
  end

  context "with 2025/26 form" do
    let(:start_date) { Time.utc(2025, 4, 1) }

    before do
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(29)
    end
  end
end
