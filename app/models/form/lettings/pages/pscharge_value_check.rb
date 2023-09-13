class Form::Lettings::Pages::PschargeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "pscharge_value_check"
    @depends_on = [{ "pscharge_over_soft_max?" => true }]
    @title_text = {
      "translation" => "soft_validations.pscharge.title_text",
    }
    @informative_text = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PschargeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype pscharge]
  end
end
