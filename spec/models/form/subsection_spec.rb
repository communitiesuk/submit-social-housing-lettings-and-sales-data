require "rails_helper"
require_relative "../../request_helper"

RSpec.describe Form::Subsection, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:lettings_log) { FactoryBot.build(:lettings_log) }
  let(:form) { instance_double(Form, conditional_question_conditions: []) }
  let(:section) { instance_double(Form::Section, form:) }
  let(:subsection_id) { "household_characteristics" }
  let(:subsection_definition) do
    {
      "label" => "Household characteristics",
      "pages" => [["tenant_code", { "questions" => { "tenancycode" => {} } }], ["person_1", { "questions" => { "age1" => {}, "sex1" => {} } }]],
    }
  end

  it "has an id" do
    expect(subsection.id).to eq(subsection_id)
  end

  it "has a copy_key defaulting to the id" do
    expect(subsection.copy_key).to eq(subsection_id)
  end

  it "has a label" do
    expect(subsection.label).to eq("Household characteristics")
  end

  it "has pages" do
    expected_pages = %w[tenant_code person_1]
    expect(subsection.pages.map(&:id)).to eq(expected_pages)
  end

  it "has questions" do
    expected_questions = %w[tenancycode age1 sex1]
    expect(subsection.questions.map(&:id)).to eq(expected_questions)
  end

  context "with an in progress lettings log" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress, tenancycode: 3, age1: 18) }

    it "has a status" do
      expect(subsection.status(lettings_log)).to eq(:in_progress)
    end

    it "has a completed status for completed subsection" do
      lettings_log.sex1 = "X"
      expect(subsection.status(lettings_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(subsection.is_incomplete?(lettings_log)).to be(true)
      expect(subsection.is_started?(lettings_log)).to be(true)
    end

    context "with optional fields" do
      it "has a started status even if only an optional field has been answered" do
        lettings_log.tenancycode = 3
        expect(subsection.is_started?(lettings_log)).to be(true)
      end
    end

    it "has question helpers for the number of applicable questions" do
      expected_questions = %w[tenancycode age1 sex1]
      expect(subsection.applicable_questions(lettings_log).map(&:id)).to eq(expected_questions)
    end
  end

  context "with a completed lettings log" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :completed) }

    it "has a status" do
      expect(subsection.status(lettings_log)).to eq(:completed)
    end

    it "has a status when optional fields are not filled" do
      lettings_log.propcode = nil
      expect(subsection.status(lettings_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(subsection.is_incomplete?(lettings_log)).to be(false)
      expect(subsection.is_started?(lettings_log)).to be(true)
    end
  end
end
