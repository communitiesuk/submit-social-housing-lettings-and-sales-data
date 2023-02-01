class Form::Lettings::Questions::HousingneedsType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "housingneeds_type"
    @check_answer_label = "Disabled access needs"
    @header = "What type of access needs do they have?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Fully wheelchair accessible housing" }, "1" => { "value" => "Wheelchair access to essential rooms" }, "2" => { "value" => "Level access housing" }, "divider" => { "value" => true }, "3" => { "value" => "None of the listed options" } }.freeze
end
