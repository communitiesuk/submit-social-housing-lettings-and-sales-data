class Form::Sales::Pages::NoAddressFound < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "no_address_found"
    @type = "interruption_screen"
    @title_text = {
      "translation" => "soft_validations.no_address_found.title_text",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "soft_validations.no_address_found.informative_text",
      "arguments" => [],
    }
    @depends_on = [{ "address_options_present?" => false }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::NoAddressFound.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[address_line1_input]
  end
end
