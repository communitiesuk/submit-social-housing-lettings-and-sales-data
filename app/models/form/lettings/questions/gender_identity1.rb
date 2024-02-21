class Form::Lettings::Questions::GenderIdentity1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex1"
    @check_answer_label = "Lead tenant’s gender identity"
    @header = "Which of these best describes the lead tenant’s gender identity?"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "divider" => { "value" => true },
    "R" => { "value" => "Tenant prefers not to say" },
  }.freeze

  def hint_text
    if form.start_year_after_2024?
      "This should be however they personally choose to identify from the options below. This may or may not be the same as their biological sex or the sex they were assigned at birth."
    else
      "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    end
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 33, 2024 => 32 }.freeze
end
