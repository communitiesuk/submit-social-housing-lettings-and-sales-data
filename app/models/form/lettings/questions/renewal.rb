class Form::Lettings::Questions::Renewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "renewal"
    @check_answer_label = "Property renewal"
    @header = header_text
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = hint_text
    @question_number = 4
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }
  .freeze

  def header_text
    if form.start_year_after_2024?
      "Is this letting a renewal of social housing to the same tenant in the same property?"
    else
      "Is this letting a renewal?"
    end
  end

  def hint_text
    if form.start_year_after_2024?
      "If the property was previously being used as temporary accommodation, then answer 'no'"
    else
      "A renewal is a letting to the same tenant in the same property. If the property was previously being used as temporary accommodation, then answer 'no'"
    end
  end
end
