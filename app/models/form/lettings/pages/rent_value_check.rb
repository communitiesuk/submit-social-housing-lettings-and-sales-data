class Form::Lettings::Pages::RentValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, check_answers_card_number: nil)
    super(id, hsh, subsection)
    @depends_on = [{ "rent_soft_validation_triggered?" => true }]
    @copy_key = "lettings.soft_validations.rent_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "brent",
          "label" => true,
          "i18n_template" => "brent",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [
        {
          "key" => "rent_soft_validation_higher_or_lower_text",
          "label" => false,
          "i18n_template" => "higher_or_lower",
        },
      ],
    }
    @check_answers_card_number = check_answers_card_number
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RentValueCheck.new(nil, nil, self, check_answers_card_number: @check_answers_card_number)]
  end

  def interruption_screen_question_ids
    %w[brent period startdate uprn postcode_full la beds rent_type needstype]
  end
end
