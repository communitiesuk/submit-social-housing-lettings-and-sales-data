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
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::NoAddressFound.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[address_line1_input]
  end

  def routed_to?(log, _)
    return false unless super
    return false if log.is_supported_housing? || log.address_options_present?
    return false if !log.uprn_known.nil? && log.uprn_known != 0 && log.uprn_confirmed != 0
    return false if log.is_new_build? && log.form.start_year_2025_or_later?

    true
  end
end
