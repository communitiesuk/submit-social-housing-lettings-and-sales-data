require "rails_helper"

RSpec.describe Form::Lettings::Questions::TenancyLength, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date:)), id: "tenancy_length") }
  let(:start_date) { Time.utc(2023, 4, 1) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("tenancylength")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "has the correct minimum and maximum" do
    expect(question.min).to eq 0
    expect(question.max).to eq 150
  end

  it "has the correct step" do
    expect(question.step).to eq 1
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "with 2024/25 form" do
    let(:start_date) { Time.utc(2024, 4, 1) }

    before do
      allow(page.subsection.form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(28)
    end
  end

  context "with 2025/26 form" do
    let(:start_date) { Time.utc(2025, 4, 1) }

    before do
      allow(page.subsection.form).to receive(:start_year_2024_or_later?).and_return(true)
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(29)
    end
  end
end
