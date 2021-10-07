require "rails_helper"

RSpec.describe StimulusControllerAttributeHelper do
  let(:form) { Form.new(2021, 2022) }
  let(:questions) { form.questions_for_page("rent") }

  describe "html attributes" do
    it "returns empty hash if fields-to-add or result-field are empty " do
      expect(stimulus_html_attributes(questions["total_charge"])).to eq({})
    end

    it "returns html attributes if fields-to-add or result-field are not empty " do
      expect(stimulus_html_attributes(questions["basic_rent"])).to eq({
        "data-controller": "numeric-question",
        "data-action": "numeric-question#calculateFields",
        "data-target": "case-log-#{questions['basic_rent']['result-field'].to_s.dasherize}-field",
        "data-calculated": questions["basic_rent"]["fields-to-add"].to_json,
      })
    end

    context "a question that requires multiple controllers" do
      let(:question) do
        {
          "check_answer_label" => "Basic Rent",
          "header" => "What is the basic rent?",
          "hint_text" => "Eligible for housing benefit or Universal Credit",
          "type" => "numeric",
          "min" => 0,
          "step" => 1,
          "fields-to-add" => %w[basic_rent service_charge personal_service_charge support_charge],
          "result-field" => "total_charge",
          "conditional_for" => {
            "next_question": ">1",
          },
        }
      end
      let(:expected_attribs) do
        {
          "data-controller": "numeric-question conditional-question",
          "data-action": "numeric-question#calculateFields conditional-question#displayConditional",
          "data-target": "case-log-#{question['result-field'].to_s.dasherize}-field",
          "data-calculated": question["fields-to-add"].to_json,
          "data-info": question["conditional_for"].to_json,
        }
      end
      it "correctly merges html attributes" do
        expect(stimulus_html_attributes(question)).to eq(expected_attribs)
      end
    end
  end
end
