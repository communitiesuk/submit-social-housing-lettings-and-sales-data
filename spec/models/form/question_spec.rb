require "rails_helper"

RSpec.describe Form::Question, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
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

  it "has an id" do
    expect(question.id).to eq(question_id)
  end

  it "has a header" do
    expect(question.header).to eq("What is the tenant’s /and partner’s combined income after tax?")
  end

  it "has a check answers label" do
    expect(question.check_answer_label).to eq("Income")
  end

  it "has a question type" do
    expect(question.type).to eq("numeric")
  end

  it "belongs to a page" do
    expect(question.page).to eq(page)
  end

  it "belongs to a subsection" do
    expect(question.subsection).to eq(subsection)
  end

  it "has a read only helper" do
    expect(question.read_only?).to be false
  end

  it "has a yes value helper" do
    expect(question.value_is_yes?("Yes")).to be_truthy
    expect(question.value_is_yes?("YES")).to be_truthy
    expect(question.value_is_yes?("random")).to be_falsey
  end

  it "has a no value helper" do
    expect(question.value_is_no?("No")).to be_truthy
    expect(question.value_is_no?("NO")).to be_truthy
    expect(question.value_is_no?("random")).to be_falsey
  end

  context "when type is numeric" do
    it "has a min value" do
      expect(question.min).to eq(0)
    end

    it "has a step value" do
      expect(question.step).to eq(1)
    end

    it "does not map value from label" do
      expect(question.value_from_label("5")).to eq("5")
    end
  end

  context "when type is radio" do
    let(:question_id) { "incfreq" }

    it "has answer options" do
      expected_answer_options = { "0" => { "value" => "Weekly" }, "1" => { "value" => "Monthly" }, "2" => { "value" => "Yearly" } }
      expect(question.answer_options).to eq(expected_answer_options)
    end

    it "can map value from label" do
      expect(question.value_from_label("Monthly")).to eq("1")
    end

    it "can map label from value" do
      expect(question.label_from_value(2)).to eq("Yearly")
    end

    context "when answer options include yes, no, prefer not to say" do
      let(:section_id) { "household" }
      let(:subsection_id) { "household_needs" }
      let(:page_id) { "medical_conditions" }
      let(:question_id) { "illness" }

      it "maps those options" do
        expect(question).to be_value_is_yes(0)
        expect(question).not_to be_value_is_no(0)
        expect(question).not_to be_value_is_refused(0)
        expect(question).to be_value_is_no(1)
        expect(question).to be_value_is_refused(2)
      end
    end

    context "when answer options includes don’t know" do
      let(:section_id) { "local_authority" }
      let(:subsection_id) { "local_authority" }
      let(:page_id) { "time_lived_in_la" }
      let(:question_id) { "layear" }

      it "maps those options" do
        expect(question).not_to be_value_is_yes(7)
        expect(question).not_to be_value_is_no(7)
        expect(question).not_to be_value_is_refused(7)
        expect(question).to be_value_is_dont_know(7)
      end
    end
  end

  context "when type is select" do
    let(:section_id) { "household" }
    let(:subsection_id) { "household_needs" }
    let(:page_id) { "accessible_select" }
    let(:question_id) { "la" }

    it "can map value from label" do
      expect(question.value_from_label("Manchester")).to eq("E08000003")
    end

    it "can map label from value" do
      expect(question.label_from_value("E06000014")).to eq("York")
    end
  end

  context "when type is checkbox" do
    let(:section_id) { "household" }
    let(:subsection_id) { "household_needs" }
    let(:page_id) { "condition_effects" }
    let(:question_id) { "condition_effects" }

    it "has answer options" do
      expected_answer_options = {
        "illness_type_1" => { "value" => "Vision - such as blindness or partial sight" },
        "illness_type_2" => { "value" => "Hearing - such as deafness or partial hearing" },
      }
      expect(question.answer_options).to eq(expected_answer_options)
    end

    it "can map yes values" do
      expect(question).to be_value_is_yes(1)
      expect(question).not_to be_value_is_yes(0)
    end

    it "can map no values" do
      expect(question).to be_value_is_no(0)
      expect(question).not_to be_value_is_no(1)
    end
  end

  context "when the question is read only" do
    let(:subsection_id) { "rent_and_charges" }
    let(:page_id) { "rent" }
    let(:question_id) { "tcharge" }

    it "has a read only helper" do
      expect(question.read_only?).to be true
    end

    context "when the answer is part of a sum" do
      let(:question_id) { "pscharge" }

      it "has a result_field" do
        expect(question.result_field).to eq("tcharge")
      end

      it "has fields to sum" do
        expected_fields_to_sum = %w[brent scharge pscharge supcharg]
        expect(question.fields_to_add).to eq(expected_fields_to_sum)
      end
    end
  end

  context "with a case log" do
    let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
    let(:question_id) { "incfreq" }

    it "has an answer label" do
      case_log.incfreq = 0
      expect(question.answer_label(case_log)).to eq("Weekly")
    end

    it "has an update answer link text helper" do
      expect(question.update_answer_link_name(case_log)).to match(/Answer/)
      case_log["incfreq"] = 0
      expect(question.update_answer_link_name(case_log)).to match(/Change/)
    end

    context "when type is date" do
      let(:section_id) { "local_authority" }
      let(:subsection_id) { "local_authority" }
      let(:page_id) { "property_major_repairs" }
      let(:question_id) { "mrcdate" }

      it "displays a formatted answer label" do
        case_log.mrcdate = Time.zone.local(2021, 10, 11)
        expect(question.answer_label(case_log)).to eq("11 October 2021")
      end

      it "can handle nils" do
        case_log.mrcdate = nil
        expect(question.answer_label(case_log)).to eq("")
      end
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
        expect(question.answer_label(case_log)).to eq(expected_answer_label)
      end
    end

    context "when a condition is present" do
      let(:page_id) { "housing_benefit" }
      let(:question_id) { "conditional_question" }

      it "knows whether it is enabled or not for unmet conditions" do
        expect(question.enabled?(case_log)).to be false
      end

      it "knows whether it is enabled or not for met conditions" do
        case_log.hb = "Housing benefit"
        expect(question.enabled?(case_log)).to be true
      end
    end

    context "when answers have a suffix dependent on another answer" do
      let(:section_id) { "rent_and_charges" }
      let(:subsection_id) { "income_and_benefits" }
      let(:page_id) { "net_income" }
      let(:question_id) { "earnings" }

      it "displays the correct label for given suffix and answer the suffix depends on" do
        case_log.incfreq = 0
        case_log.earnings = 500
        expect(question.answer_label(case_log)).to eq("£500.00 every week")
        case_log.incfreq = 1
        expect(question.answer_label(case_log)).to eq("£500.00 every month")
        case_log.incfreq = 2
        expect(question.answer_label(case_log)).to eq("£500.00 every year")
      end
    end
  end

  describe ".completed?" do
    context "when the question has inferred value only for check answers display" do
      let(:section_id) { "tenancy_and_property" }
      let(:subsection_id) { "property_information" }
      let(:page_id) { "property_postcode" }
      let(:question_id) { "property_postcode" }

      it "returns true" do
        case_log["postcode_known"] = 0
        expect(question.completed?(case_log)).to be(true)
      end
    end
  end
end
