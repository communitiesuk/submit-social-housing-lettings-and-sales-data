require "rails_helper"

RSpec.describe CheckAnswersHelper do
  let(:case_log) { FactoryBot.create(:case_log) }
  let(:case_log_with_met_numeric_condition) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      household_number_of_other_members: 1,
      person_2_relationship: "Partner",
    )
  end
  let(:case_log_with_met_radio_condition) do
    FactoryBot.create(:case_log, armed_forces: "Yes - a regular")
  end
  let(:subsection) { "income_and_benefits" }
  let(:subsection_with_numeric_conditionals) { "household_characteristics" }
  let(:subsection_with_radio_conditionals) { "household_needs" }
  let(:form) { Form.new("test", "form") }

  describe "Get answered questions total" do
    it "returns 0 if no questions are answered" do
      expect(total_answered_questions(subsection, case_log, form)).to equal(0)
    end

    it "returns 1 if 1 question gets answered" do
      case_log["net_income"] = "123"
      expect(total_answered_questions(subsection, case_log, form)).to equal(1)
    end

    it "ignores questions with unmet numeric conditions" do
      case_log["tenant_code"] = "T1234"
      expect(total_answered_questions(subsection_with_numeric_conditionals, case_log, form)).to equal(1)
    end

    it "includes conditional questions with met numeric conditions" do
      expect(total_answered_questions(
               subsection_with_numeric_conditionals,
               case_log_with_met_numeric_condition,
               form,
             )).to equal(4)
    end

    it "ignores questions with unmet radio conditions" do
      case_log["armed_forces"] = "No"
      expect(total_answered_questions(subsection_with_radio_conditionals, case_log, form)).to equal(1)
    end

    it "includes conditional questions with met radio conditions" do
      case_log_with_met_radio_condition["armed_forces_injured"] = "No"
      case_log_with_met_radio_condition["medical_conditions"] = "No"
      expect(total_answered_questions(
               subsection_with_radio_conditionals,
               case_log_with_met_radio_condition,
               form,
             )).to equal(3)
    end
  end

  describe "Get total number of questions" do
    it "returns the total number of questions for a subsection" do
      expect(total_number_of_questions(subsection, case_log, form)).to eq(4)
    end

    it "ignores questions with unmet numeric conditions" do
      expect(total_number_of_questions(subsection_with_numeric_conditionals, case_log, form)).to eq(4)
    end

    it "includes conditional questions with met numeric conditions" do
      expect(total_number_of_questions(
               subsection_with_numeric_conditionals,
               case_log_with_met_numeric_condition,
               form,
             )).to eq(8)
    end

    it "ignores questions with unmet radio conditions" do
      expect(total_number_of_questions(subsection_with_radio_conditionals, case_log, form)).to eq(4)
    end

    it "includes conditional questions with met radio conditions" do
      expect(total_number_of_questions(
               subsection_with_radio_conditionals,
               case_log_with_met_radio_condition,
               form,
             )).to eq(6)
    end

    context "conditional questions with type that hasn't been implemented yet" do
      let(:unimplemented_conditional) do
        { "question_1" =>
          { "header" => "The actual question?",
            "hint_text" => "",
            "type" => "date",
            "check_answer_label" => "Question Label",
            "conditional_for" => { "question_2" => %w[12-12-2021] } },
          "question_2" =>
          { "header" => "The second actual question?",
            "hint_text" => "",
            "type" => "radio",
            "check_answer_label" => "The second question label",
            "answer_options" => { "0" => "Yes", "1" => "No" } } }
      end

      it "raises an error" do
        allow_any_instance_of(Form).to receive(:questions_for_subsection).and_return(unimplemented_conditional)
        expect { total_number_of_questions(subsection, case_log, form) }.to raise_error(RuntimeError, "Not implemented yet")
      end
    end
  end
end
