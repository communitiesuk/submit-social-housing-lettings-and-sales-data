class Form::Sales::Questions::LaNominations < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "lanomagr"
    @check_answer_label = "Household rehoused under a local authority nominations agreement?"
    @header = "Was the household rehoused under a 'local authority nominations agreement'?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "A local authority nominations agreement is a written agreement between a local authority and private registered provider (PRP) that some or all of its sales vacancies are offered to local authorities for rehousing"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 83, 2024 => 85 }.freeze
end
