class Form::Lettings::Pages::ReasonotherValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "reasonother_value_check"
    @depends_on = [{ "reasonother_might_be_existing_category?" => true }]
    @title_text = {
      "translation" => "soft_validations.reasonother.title_text",
      "arguments" => [{ "key" => "reasonother", "i18n_template" => "reasonother" }],
    }
    @informative_text = "The reason you have entered looks very similar to one of the existing response categories.
                         Please check the categories and select the appropriate one.
                         If the existing categories are not suitable, please confirm here to move onto the next question."
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReasonotherValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[reason reasonother]
  end
end
