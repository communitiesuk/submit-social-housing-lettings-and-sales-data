require "rails_helper"

RSpec.describe QuestionAttributeHelper do
  let(:lettings_log) { FactoryBot.build(:lettings_log) }
  let(:form) { lettings_log.form }
  let(:questions) { form.get_page("rent").questions }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  before do
    allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
  end

  describe "html attributes" do
    it "returns empty hash if fields-to-add or result-field are empty " do
      question = form.get_page("weekly_net_income").questions.find { |q| q.id == "earnings" }
      expect(stimulus_html_attributes(question)).to eq({})
    end

    it "returns html attributes if fields-to-add or result-field are not empty " do
      brent = questions.find { |q| q.id == "brent" }
      expect(stimulus_html_attributes(brent)).to eq({
        "data-controller": "numeric-question",
        "data-action": "input->numeric-question#calculateFields",
        "data-target": "lettings-log-#{brent.result_field.to_s.dasherize}-field",
        "data-calculated": brent.fields_to_add.to_json,
      })
    end

    context "when a question that requires multiple controllers" do
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
        }, form.get_page("rent"))
      end
      let(:expected_attribs) do
        {
          "data-controller": "numeric-question conditional-question",
          "data-action": "input->numeric-question#calculateFields click->conditional-question#displayConditional",
          "data-target": "lettings-log-#{question.result_field.to_s.dasherize}-field",
          "data-calculated": question.fields_to_add.to_json,
          "data-info": { conditional_questions: question.conditional_for, log_type: "lettings" }.to_json,
        }
      end

      it "correctly merges html attributes" do
        expect(stimulus_html_attributes(question)).to eq(expected_attribs)
      end
    end
  end
end
