class Form::Lettings::Pages::SupchargValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "supcharg_value_check"
    @depends_on = [{ "supcharg_over_soft_max?" => true }]
    @title_text = {
      "translation" => "soft_validations.supcharg.title_text",
    }
    @informative_text = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::SupchargValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype supcharg]
  end
end
