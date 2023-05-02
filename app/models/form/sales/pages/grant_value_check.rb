class Form::Sales::Pages::GrantValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "grant_value_check"
    @depends_on = [
      {
        "grant_outside_common_range?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.grant.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "grant",
          "i18n_template" => "grant",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.grant.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::GrantValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[grant]
  end
end
