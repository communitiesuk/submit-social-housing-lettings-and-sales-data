require "rails_helper"

RSpec.describe Form::Sales::Questions::Mortgageused, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form:)) }
  let(:log) { build(:sales_log) }

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
      "3" => { "value" => "Don’t know" },
    })
  end

  context "when staircase owned percentage is 100%" do
    let(:log) { build(:sales_log, stairowned: 100) }

    it "shows the don't know option" do
      expect(question.displayed_answer_options(log)).to eq({
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
        "3" => { "value" => "Don’t know" },
      })
    end
  end

  context "when an outright sale" do
    subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 3) }

    it "shows the don't know option" do
      expect(question.displayed_answer_options(log)).to eq({
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
        "3" => { "value" => "Don’t know" },
      })
    end
  end

  context "when staircase owned percentage is less than 100%" do
    let(:log) { build(:sales_log, stairowned: 99) }

    it "shows the don't know option" do
      expect(question.displayed_answer_options(log)).to eq({
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
      })
    end
  end
end
