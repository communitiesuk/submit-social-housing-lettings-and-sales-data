require "rails_helper"

RSpec.describe QuestionAttributeHelper do
  let(:case_log) { FactoryBot.build(:case_log) }
  let(:form) { case_log.form }
  let(:questions) { form.get_page("rent").questions }

  describe "html attributes" do
    it "returns empty hash if fields-to-add or result-field are empty " do
      question = form.get_page("weekly_net_income").questions.find { |q| q.id == "earnings" }
      expect(stimulus_html_attributes(question)).to eq({})
    end

    it "returns html attributes if fields-to-add or result-field are not empty " do
      brent = questions.find { |q| q.id == "brent" }
      expect(stimulus_html_attributes(brent)).to eq({
        "data-controller": "numeric-question",
        "data-action": "numeric-question#calculateFields",
        "data-target": "case-log-#{brent.result_field.to_s.dasherize}-field",
        "data-calculated": brent.fields_to_add.to_json,
      })
    end

    context "a question that requires multiple controllers" do
      let(:question) do
        Form::Question.new("brent", {
          "check_answer_label" => "Basic Rent",
          "header" => "What is the basic rent?",
          "hint_text" => "Eligible for housing benefit or Universal Credit",
          "type" => "numeric",
          "min" => 0,
          "step" => 1,
          "fields-to-add" => %w[brent scharge pscharge supcharg],
          "result-field" => "tcharge",
          "conditional_for" => {
            "next_question": ">1",
          },
        }, nil)
      end
      let(:expected_attribs) do
        {
          "data-controller": "numeric-question conditional-question",
          "data-action": "numeric-question#calculateFields conditional-question#displayConditional",
          "data-target": "case-log-#{question.result_field.to_s.dasherize}-field",
          "data-calculated": question.fields_to_add.to_json,
          "data-info": question.conditional_for.to_json,
        }
      end
      it "correctly merges html attributes" do
        expect(stimulus_html_attributes(question)).to eq(expected_attribs)
      end
    end
  end
end
