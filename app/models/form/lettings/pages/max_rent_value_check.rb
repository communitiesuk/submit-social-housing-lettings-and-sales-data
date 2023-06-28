class Form::Lettings::Pages::MaxRentValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, check_answers_card_number: nil)
    super(id, hsh, subsection)
    @depends_on = [{ "rent_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "soft_validations.rent.outside_range_title",
      "arguments" => [
        {
          "key" => "brent",
          "label" => true,
          "i18n_template" => "brent",
        },
      ],
    }
    # @informative_text = {}
    @informative_text = {
      "translation" => "soft_validations.rent.max_hint_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "soft_max_for_period",
          "i18n_template" => "soft_max_for_period",
        },
      ],
    }

    @check_answers_card_number = check_answers_card_number
  end

  def questions
    @questions ||= [Form::Lettings::Questions::MaxRentValueCheck.new(nil, nil, self, check_answers_card_number: @check_answers_card_number)]
  end

  def interruption_screen_question_ids
    %w[brent startdate uprn postcode_full la beds rent_type needstype]
  end
end
