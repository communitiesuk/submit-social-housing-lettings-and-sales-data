class Form::Sales::Questions::Prevshared < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevshared"
    @check_answer_label = "Previous property shared ownership?"
    @header = "Was the previous property a shared ownership property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint = "For any buyer"
    @question_number = 74
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
