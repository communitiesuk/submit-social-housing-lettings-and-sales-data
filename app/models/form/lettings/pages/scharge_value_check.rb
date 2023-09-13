class Form::Lettings::Pages::SchargeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "scharge_value_check"
    @depends_on = [{ "scharge_over_soft_max?" => true }]
    @title_text = {
      "translation" => "soft_validations.scharge.title_text",
    }
    @informative_text = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::SchargeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype scharge]
  end
end
