require "rails_helper"

RSpec.describe CheckAnswersHelper do
  let(:case_log) { FactoryBot.create(:case_log) }
  let(:case_log_with_met_numeric_condition) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      other_hhmemb: 1,
      relat2: "Partner",
    )
  end
  let(:case_log_with_met_radio_condition) do
    FactoryBot.create(:case_log, armed_forces: "Yes - a regular",
                                 reservist: "No",
                                 leftreg: "Yes")
  end
  let(:subsection) { "income_and_benefits" }
  let(:subsection_with_numeric_conditionals) { "household_characteristics" }
  let(:subsection_with_radio_conditionals) { "household_needs" }
  let(:conditional_routing_subsection) { "conditional_question" }
  let(:conditional_page_subsection) { "household_needs" }
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }

  describe "Get answered questions total" do
    it "returns 0 if no questions are answered" do
      expect(total_answered_questions(subsection, case_log, form)).to equal(0)
    end

    it "returns 1 if 1 question gets answered" do
      case_log["earnings"] = "123"
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
      case_log_with_met_radio_condition["reservist"] = "No"
      case_log_with_met_radio_condition["illness"] = "No"
      expect(total_answered_questions(
               subsection_with_radio_conditionals,
               case_log_with_met_radio_condition,
               form,
             )).to equal(4)
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
        { "previous_postcode" =>
          { "header" => "The actual question?",
            "hint_text" => "",
            "type" => "date",
            "check_answer_label" => "Question Label",
            "conditional_for" => { "question_2" => %w[12-12-2021] } } }
      end

      it "raises an error" do
        allow_any_instance_of(Form).to receive(:questions_for_page).and_return(unimplemented_conditional)
        expect { total_number_of_questions(subsection, case_log, form) }.to raise_error(RuntimeError, "Not implemented yet")
      end
    end

    context "conditional routing" do
      it "ignores not visited questions when no questions are answered" do
        expect(total_number_of_questions(conditional_routing_subsection, case_log, form)).to eq(1)
      end

      it "counts correct questions when the conditional question is answered" do
        case_log["preg_occ"] = "Yes"
        expect(total_number_of_questions(conditional_routing_subsection, case_log, form)).to eq(2)
      end

      it "counts correct questions when the conditional question is answered" do
        case_log["preg_occ"] = "No"
        case_log["sex1"] = "Male"
        expect(total_number_of_questions(conditional_routing_subsection, case_log, form)).to eq(3)
      end
    end

    context "total questions" do
      it "returns total questions" do
        result = total_questions(subsection, case_log, form)
        expected_keys = %w[earnings incfreq benefits hb]
        expect(result.keys).to eq(expected_keys)
      end

      context "conditional questions on the same page" do
        it "it filters out conditional questions that were not displayed" do
          result = total_questions(conditional_page_subsection, case_log, form)
          expected_keys = %w[armed_forces illness accessibility_requirements condition_effects]
          expect(result.keys).to eq(expected_keys)
        end

        it "it includes conditional questions that were displayed" do
          case_log["armed_forces"] = "Yes - a regular"
          result = total_questions(conditional_page_subsection, case_log, form)
          expected_keys = %w[armed_forces leftreg reservist illness accessibility_requirements condition_effects]
          expect(result.keys).to eq(expected_keys)
        end
      end

      context "conditional routing" do
        it "it ignores skipped pages and the questions therein when conditional routing" do
          result = total_questions(conditional_routing_subsection, case_log, form)
          expected_keys = %w[preg_occ]
          expect(result.keys).to match_array(expected_keys)
        end

        it "it includes conditional pages and questions that were displayed" do
          case_log["preg_occ"] = "Yes"
          case_log["sex1"] = "Female"
          result = total_questions(conditional_routing_subsection, case_log, form)
          expected_keys = %w[preg_occ cbl]
          expect(result.keys).to match_array(expected_keys)
        end

        it "it includes conditional pages and questions that were displayed" do
          case_log["preg_occ"] = "No"
          result = total_questions(conditional_routing_subsection, case_log, form)
          expected_keys = %w[preg_occ conditional_question_no_question]
          expect(result.keys).to match_array(expected_keys)
        end
      end
    end
  end
end
