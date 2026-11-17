class Form::Lettings::Pages::LocationPostcodeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "location_postcode_value_check"
    @copy_key = "lettings.soft_validations.location_postcode_value_check"
    @depends_on = [{ "postcode_does_not_match_location_postcode?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "postcode_full",
          "label" => false,
          "i18n_template" => "postcode_full",
        },
        {
          "key" => "location_postcode",
          "label" => false,
          "i18n_template" => "location_postcode",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::LocationPostcodeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[location_id uprn postcode_full]
  end
end
