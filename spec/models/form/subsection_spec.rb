require "rails_helper"

RSpec.describe Form::Subsection, type: :model do
  subject(:sub_section) { described_class.new(subsection_id, subsection_definition, section) }

  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
  let(:section_id) { "household" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "household_characteristics" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }

  it "has an id" do
    expect(sub_section.id).to eq(subsection_id)
  end

  it "has a label" do
    expect(sub_section.label).to eq("Household characteristics")
  end

  it "has pages" do
    expected_pages = %w[tenant_code person_1_age person_1_gender household_number_of_other_members]
    expect(sub_section.pages.map(&:id)).to eq(expected_pages)
  end

  it "has questions" do
    expected_questions = %w[tenant_code age1 sex1 other_hhmemb relat2 age2 sex2 ecstat2]
    expect(sub_section.questions.map(&:id)).to eq(expected_questions)
  end

  context "with an in progress case log" do
    let(:case_log) { FactoryBot.build(:case_log, :in_progress) }

    it "has a status" do
      expect(sub_section.status(case_log)).to eq(:in_progress)
    end

    it "has a completed status for completed subsection" do
      subsection_definition = section_definition["subsections"]["household_needs"]
      sub_section = described_class.new("household_needs", subsection_definition, section)
      case_log.armedforces = "No"
      case_log.illness = "No"
      case_log.housingneeds_a = "Yes"
      case_log.la = "York"
      case_log.illness_type_1 = "Yes"
      expect(sub_section.status(case_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(sub_section.is_incomplete?(case_log)).to be(true)
      expect(sub_section.is_started?(case_log)).to be(true)
    end

    it "has question helpers for the number of applicable questions" do
      expected_questions = %w[tenant_code age1 sex1 other_hhmemb]
      expect(sub_section.applicable_questions(case_log).map(&:id)).to eq(expected_questions)
      expect(sub_section.applicable_questions_count(case_log)).to eq(4)
    end

    it "has question helpers for the number of answered questions" do
      subsection_definition = section_definition["subsections"]["household_needs"]
      sub_section = described_class.new("household_needs", subsection_definition, section)
      expected_questions = %w[armedforces illness accessibility_requirements la condition_effects]
      case_log.armedforces = "No"
      case_log.illness = "No"
      case_log.housingneeds_a = "Yes"
      case_log.la = "York"
      case_log.illness_type_1 = "Yes"
      expect(sub_section.answered_questions(case_log).map(&:id)).to eq(expected_questions)
      expect(sub_section.answered_questions_count(case_log)).to eq(5)
    end

    it "has a question helpers for the unanswered questions" do
      expected_questions = %w[sex1 other_hhmemb]
      expect(sub_section.unanswered_questions(case_log).map(&:id)).to eq(expected_questions)
    end
  end

  context "when the privacy notice has not been shown" do
    let(:section_id) { "setup" }
    let(:subsection_id) { "setup" }
    let(:case_log) { FactoryBot.build(:case_log, :about_completed, gdpr_acceptance: "No") }

    it "does not mark the section as completed" do
      expect(sub_section.status(case_log)).to eq(:in_progress)
    end
  end

  context "with a completed case log" do
    let(:case_log) { FactoryBot.build(:case_log, :completed) }

    it "has a status" do
      expect(sub_section.status(case_log)).to eq(:completed)
    end

    it "has status helpers" do
      expect(sub_section.is_incomplete?(case_log)).to be(false)
      expect(sub_section.is_started?(case_log)).to be(true)
    end
  end
end
