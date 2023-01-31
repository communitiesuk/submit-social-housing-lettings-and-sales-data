class Form::Sales::Pages::StaircaseBoughtValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "staircase_bought_value_check"
    @depends_on = [
      {
        "staircase_bought_above_fifty?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.staircase_bought_seems_high",
      "arguments" => [
        {
          "key" => "stairbought",
          "i18n_template" => "percentage",
        },
      ],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseBoughtValueCheck.new(nil, nil, self),
    ]
  end
end
