require "rails_helper"
require_relative "../../request_helper"

RSpec.describe Form::Subsection, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
  let(:section_id) { "household" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "household_characteristics" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }

  before do
    RequestHelper.stub_http_requests
  end

  it "has an id" do
    expect(subsection.id).to eq(subsection_id)
  end

  it "has a label" do
    expect(subsection.label).to eq("Household characteristics")
  end

  it "has pages" do
    expected_pages = %w[teanncycode person_1_age person_1_gender person_1_working_situation household_number_of_members person_2_working_situation propcode]
    expect(subsection.pages.map(&:id)).to eq(expected_pages)
  end

  it "has questions" do
    expected_questions = %w[teanncycode age1 sex1 ecstat1 hhmemb relat2 age2 sex2 ecstat2 propcode]
    expect(subsection.questions.map(&:id)).to eq(expected_questions)
  end

  context "with an in progress case log" do
    let(:case_log) { FactoryBot.build(:case_log, :in_progress) }

    it "has a status" do
      expect(subsection.status(case_log)).to eq(:in_progress)
    end

    it "has a completed status for completed subsection" do
      subsection_definition = section_definition["subsections"]["household_needs"]
      subsection = described_class.new("household_needs", subsection_definition, section)
      case_log.armedforces = 3
      case_log.illness = 1
      case_log.housingneeds_a = 1
      case_log.la = "E06000014"
      case_log.illness_type_1 = 1
      expect(subsection.status(case_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(subsection.is_incomplete?(case_log)).to be(true)
      expect(subsection.is_started?(case_log)).to be(true)
    end

    context "with optional fields" do
      subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

      let(:section_id) { "tenancy_and_property" }
      let(:section_definition) { form.form_definition["sections"][section_id] }
      let(:section) { Form::Section.new(section_id, section_definition, form) }
      let(:subsection_id) { "property_information" }
      let(:subsection_definition) { section_definition["subsections"][subsection_id] }

      it "has a started status even if only an optional field has been answered" do
        case_log.postcode_known = 0
        expect(subsection.is_started?(case_log)).to be(true)
      end
    end

    it "has question helpers for the number of applicable questions" do
      expected_questions = %w[teanncycode age1 sex1 ecstat1 hhmemb ecstat2 propcode]
      expect(subsection.applicable_questions(case_log).map(&:id)).to eq(expected_questions)
      expect(subsection.applicable_questions_count(case_log)).to eq(7)
    end

    it "has question helpers for the number of answered questions" do
      subsection_definition = section_definition["subsections"]["household_needs"]
      subsection = described_class.new("household_needs", subsection_definition, section)
      expected_questions = %w[armedforces illness accessibility_requirements prevloc condition_effects]
      case_log.armedforces = 3
      case_log.illness = 1
      case_log.housingneeds_a = 1
      case_log.previous_la_known = 1
      case_log.is_previous_la_inferred = false
      case_log.prevloc = "E06000014"
      case_log.illness_type_1 = 1
      expect(subsection.answered_questions(case_log).map(&:id)).to eq(expected_questions)
      expect(subsection.answered_questions_count(case_log)).to eq(5)
    end

    it "has a question helpers for the unanswered questions" do
      expected_questions = %w[sex1 ecstat1 hhmemb ecstat2 propcode]
      expect(subsection.unanswered_questions(case_log).map(&:id)).to eq(expected_questions)
    end
  end

  context "with a completed case log" do
    let(:case_log) { FactoryBot.build(:case_log, :completed) }

    it "has a status" do
      expect(subsection.status(case_log)).to eq(:completed)
    end

    it "has a status when optional fields are not filled" do
      case_log.update!({ propcode: nil })
      case_log.reload
      expect(subsection.status(case_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(subsection.is_incomplete?(case_log)).to be(false)
      expect(subsection.is_started?(case_log)).to be(true)
    end
  end
end
