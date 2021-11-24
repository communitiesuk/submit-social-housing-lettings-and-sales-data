require "rails_helper"

RSpec.describe Form::Question, type: :model do
  let(:form) { FormHandler.instance.get_form("test_form") }
  let(:section_id) { "rent_and_charges" }
  let(:section_definition) { form.form_definition["sections"][section_id] }
  let(:section) { Form::Section.new(section_id, section_definition, form) }
  let(:subsection_id) { "income_and_benefits" }
  let(:subsection_definition) { section_definition["subsections"][subsection_id] }
  let(:subsection) { Form::Subsection.new(subsection_id, subsection_definition, section) }
  let(:page_id) { "net_income" }
  let(:page_definition) { subsection_definition["pages"][page_id] }
  let(:page) { Form::Page.new(page_id, page_definition, subsection) }
  let(:question_id) { "earnings" }
  let(:question_definition) { page_definition["questions"][question_id] }
  subject { Form::Question.new(question_id, question_definition, page) }

  it "has an id" do
    expect(subject.id).to eq(question_id)
  end

  it "has a header" do
    expect(subject.header).to eq("What is the tenant’s /and partner’s combined income after tax?")
  end

  it "has a check answers label" do
    expect(subject.check_answer_label).to eq("Income")
  end

  it "has a question type" do
    expect(subject.type).to eq("numeric")
  end

  it "belongs to a page" do
    expect(subject.page).to eq(page)
  end

  it "belongs to a subsection" do
    expect(subject.subsection).to eq(subsection)
  end

  it "has a read only helper" do
    expect(subject.read_only?).to be false
  end

  context "when type is numeric" do
    it "has a min value" do
      expect(subject.min).to eq(0)
    end

    it "has a step value" do
      expect(subject.step).to eq(1)
    end
  end

  context "when type is radio" do
    let(:question_id) { "incfreq" }

    it "has answer options" do
      expected_answer_options = { "0" => "Weekly", "1" => "Monthly", "2" => "Yearly" }
      expect(subject.answer_options).to eq(expected_answer_options)
    end
  end

  context "when type is checkbox" do
    let(:page_id) { "dependent_page" }
    let(:question_id) { "dependent_question" }

    it "has answer options" do
      expected_answer_options = { "0" => "Option A", "1" => "Option B" }
      expect(subject.answer_options).to eq(expected_answer_options)
    end
  end

  context "when the question is read only" do
    let(:subsection_id) { "rent" }
    let(:page_id) { "rent" }
    let(:question_id) { "tcharge" }

    it "has a read only helper" do
      expect(subject.read_only?).to be true
    end

    context "when the answer is part of a sum" do
      let(:question_id) { "pscharge" }

      it "has a result_field" do
        expect(subject.result_field).to eq("tcharge")
      end

      it "has fields to sum" do
        expected_fields_to_sum = %w[brent scharge pscharge supcharg]
        expect(subject.fields_to_add).to eq(expected_fields_to_sum)
      end
    end
  end

  context "for a given case log" do
    let(:case_log) { FactoryBot.build(:case_log, :in_progress) }

    it "has an answer label" do
      case_log.earnings = 100
      expect(subject.answer_label(case_log)).to eq("100")
    end

    it "has an update answer link text helper" do
      expect(subject.update_answer_link_name(case_log)).to eq("Answer")
      case_log[question_id] = 5
      expect(subject.update_answer_link_name(case_log)).to eq("Change")
    end

    context "when type is checkbox" do
      let(:section_id) { "household" }
      let(:subsection_id) { "household_needs" }
      let(:page_id) { "accessibility_requirements" }
      let(:question_id) { "accessibility_requirements" }

      it "has a joined answers label" do
        case_log.housingneeds_a = 1
        case_log.housingneeds_c = 1
        expected_answer_label = "Fully wheelchair accessible housing, Level access housing"
        expect(subject.answer_label(case_log)).to eq(expected_answer_label)
      end
    end

    context "when a condition is present" do
      let(:page_id) { "housing_benefit" }
      let(:question_id) { "conditional_question" }

      it "knows whether it is enabled or not for unmet conditions" do
        expect(subject.enabled?(case_log)).to be false
      end

      it "knows whether it is enabled or not for met conditions" do
        case_log.hb = "Housing Benefit, but not Universal Credit"
        expect(subject.enabled?(case_log)).to be true
      end
    end
  end
end
