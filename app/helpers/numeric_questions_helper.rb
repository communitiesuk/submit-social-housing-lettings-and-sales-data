module NumericQuestionsHelper
  def numeric_question_html_attributes(question)
    return {} if question["fields-to-add"].blank? || question["result-field"].blank?

    {
      "data-controller": "numeric-question",
      "data-action": "numeric-question#calculateFields",
      "data-target": "case-log-#{question['result-field'].to_s.dasherize}-field",
      "data-calculated": question["fields-to-add"].to_json,
    }
  end
end
