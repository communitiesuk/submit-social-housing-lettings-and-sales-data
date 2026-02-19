require "rails_helper"

RSpec.describe Form::Sales::Questions::ServiceCharge, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, staircasing:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:)) }
  let(:page) { instance_double(Form::Page, subsection:) }
  let(:start_date) { Time.utc(2023, 4, 1) }
  let(:staircasing) { false }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mscharge")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct width" do
    expect(question.width).to be 5
  end

  it "has the correct min" do
    expect(question.min).to be 1
  end

  it "has the correct prefix" do
    expect(question.prefix).to eq("£")
  end

  context "with 2025/26 form" do
    let(:start_date) { Time.utc(2025, 4, 1) }

    before do
      allow(subsection.form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    context "when not staircasing" do
      let(:staircasing) { false }

      it "has the correct question number" do
        expect(question.question_number).to eq(88)
      end
    end
  end

  context "with 2026/27 form" do
    let(:start_date) { Time.utc(2026, 4, 1) }

    before do
      allow(subsection.form).to receive(:start_year_2026_or_later?).and_return(true)
    end

    context "when staircasing" do
      let(:staircasing) { true }

      it "has the correct question number" do
        expect(question.question_number).to eq(0)
      end
    end

    context "when not staircasing" do
      let(:staircasing) { false }

      it "has the correct question number" do
        expect(question.question_number).to eq(0)
      end
    end
  end
end
