class Form::Lettings::Questions::IsCarehome < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "is_carehome"
    @check_answer_label = "Care home accommodation"
    @header = "Is this accommodation a care home?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "chcharge" => [1] }
    @question_number = 93
  end

  ANSWER_OPTIONS = { "0" => { "value" => "No" }, "1" => { "value" => "Yes" } }.freeze
end
