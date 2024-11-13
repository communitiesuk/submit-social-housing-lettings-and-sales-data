require "rails_helper"

RSpec.describe Form::Sales::Questions::Staircase, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }

  context "when start year is 2024" do
    let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1)), id: "sale_information")) }

    before do
      allow(page.subsection.form).to receive(:start_year_2025_or_later?).and_return(false)
    end

    it "has correct page" do
      expect(question.page).to eq(page)
    end

    it "has the correct id" do
      expect(question.id).to eq("staircase")
    end

    it "has the correct type" do
      expect(question.type).to eq("radio")
    end

    it "is not marked as derived" do
      expect(question.derived?(nil)).to be false
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
        "3" => { "value" => "Don’t know" },
      })
    end

    it "has correct conditional for" do
      expect(question.conditional_for).to eq(nil)
    end
  end

  context "when start year is 2025" do
    let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2025, 4, 1)), id: "setup")) }

    before do
      allow(page.subsection.form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
      })
    end
  end
end
