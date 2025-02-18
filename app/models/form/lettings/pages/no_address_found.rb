class Form::Lettings::Pages::NoAddressFound < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "no_address_found"
    @type = "interruption_screen"
    @copy_key = "lettings.soft_validations.no_address_found"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
    @depends_on = [
      { "is_supported_housing?" => false, "uprn_known" => nil, "address_options_present?" => false },
      { "is_supported_housing?" => false, "uprn_known" => 0, "address_options_present?" => false },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0, "address_options_present?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::NoAddressFound.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[address_line1_input]
  end
end
