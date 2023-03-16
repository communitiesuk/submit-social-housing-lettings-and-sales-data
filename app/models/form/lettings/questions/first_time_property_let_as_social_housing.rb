class Form::Lettings::Questions::FirstTimePropertyLetAsSocialHousing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "first_time_property_let_as_social_housing"
    @check_answer_label = "First time being let as social-housing?"
    @header = "Is this the first time the property has been let as social housing?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 14
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes", "hint" => "This is a new let." },
    "0" => { "value" => "No", "hint" => "This is a re-let of existing social housing." },
  }.freeze
end
