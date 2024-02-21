class Form::Lettings::Questions::Age1Known < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1_known"
    @check_answer_label = ""
    @header = "Do you know the lead tenant’s age?"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age1" => [0] }
    @hidden_in_check_answers = { "depends_on" => [{ "age1_known" => 0 }, { "age1_known" => 1 }] }
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  def hint_text
    if form.start_year_after_2024?
      "The ’lead’ or ’main’ tenant is the person in the household who does the most paid work. If several people do the same amount of paid work, the lead tenant is whoever is the oldest."
    else
      "The ’lead’ or ’main’ tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    end
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 32, 2024 => 31 }.freeze
end
