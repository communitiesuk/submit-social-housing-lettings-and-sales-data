class Form::Lettings::Questions::PersonPartner < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "relat#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @answer_options = answer_options
    @person_index = person_index
    @question_number = question_number
    @disable_clearing_if_not_routed_or_dynamic_answer_options = form.start_year_2026_or_later?
  end

  def answer_options
    {
      "P" => { "value" => "Yes" },
      "X" => { "value" => "No" },
      "R" => { "value" => "Tenant prefers not to say" },
    }
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             30
                           when 2024
                             29
                           when 2025
                             29
                           when 2026
                             28
                           else
                             28
                           end

    base_question_number + (form.person_question_count * @person_index)
  end

  def derived?(log)
    form.start_year_2026_or_later? && log.is_person_under_16(@person_index)
  end
end
