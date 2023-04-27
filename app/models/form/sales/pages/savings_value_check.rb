class Form::Sales::Pages::SavingsValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "savings_over_soft_max?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.savings.title_text",
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SavingsValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[savings]
  end
end
