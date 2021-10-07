require "rails_helper"

RSpec.describe NumericQuestionsHelper do
  let(:form) { Form.new(2021, 2022) }
  let(:questions) { form.questions_for_page("rent") }

  describe "html attributes" do
    it "returns empty hash if fields-to-add or result-field are empty " do
      expect(numeric_question_html_attributes(questions["total_charge"])).to eq({})
    end

    it "returns html attributes if fields-to-add or result-field are not empty " do
      expect(numeric_question_html_attributes(questions["basic_rent"])).to eq({
        "data-controller": "numeric-question",
        "data-action": "numeric-question#calculateFields",
        "data-target": "#{questions['basic_rent']['result-field'].to_s.dasherize}-field",
        "data-calculated": questions["basic_rent"]["fields-to-add"].to_json,
      })
    end
  end
end
