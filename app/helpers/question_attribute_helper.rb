module QuestionAttributeHelper
  def stimulus_html_attributes(question)
    attribs = [
      numeric_question_html_attributes(question),
      conditional_html_attributes(question),
    ]
    merge_controller_attributes(*attribs)
  end

  def basic_conditional_html_attributes(conditional_for, type)
    {
      "data-controller": "conditional-question",
      "data-action": "click->conditional-question#displayConditional",
      "data-info": { conditional_questions: conditional_for, type: type }.to_json,
    }
  end

private

  def numeric_question_html_attributes(question)
    return { "style": "background-color: #f3f2f1;" } if question.read_only?
    return {} if question.fields_to_add.blank? || question.result_field.blank?

    {
      "data-controller": "numeric-question",
      "data-action": "input->numeric-question#calculateFields",
      "data-target": "lettings-log-#{question.result_field.to_s.dasherize}-field",
      "data-calculated": question.fields_to_add.to_json,
    }
  end

  def conditional_html_attributes(question)
    return {} if question.conditional_for.blank?

    {
      "data-controller": "conditional-question",
      "data-action": "click->conditional-question#displayConditional",
      "data-info": { conditional_questions: question.conditional_for, type: "#{question.form.type}-log" }.to_json,
    }
  end
end

def merge_controller_attributes(*args)
  args.flat_map(&:keys).uniq.each_with_object({}) do |key, hsh|
    hsh[key] = args.map { |a| a.fetch(key, "") }.join(" ").strip
    hsh
  end
end
