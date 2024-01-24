class Form::Lettings::Questions::FirstTimePropertyLetAsSocialHousing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "first_time_property_let_as_social_housing"
    @check_answer_label = "First time being let as social-housing?"
    @header = "Is this the first time the property has been let as social housing?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = answer_options
    @question_number = 14
  end

  def answer_options
    {
      "1" => { "value" => "Yes", "hint" => yes_hint },
      "0" => { "value" => "No", "hint" => no_hint },
    }.freeze
  end

  def yes_hint
    form.start_year_after_2024? ? "This property was previously used for other purposes or is a new-build." : "This is a new let."
  end

  def no_hint
    form.start_year_after_2024? ? "This is a re-let of existing social housing stock." : "This is a re-let of existing social housing."
  end
end
