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
                           else
                             29
                           end

    base_question_number + (4 * @person_index)
  end

  def derived?(log)
    form.start_year_2026_or_later? && log.is_partner_inferred?(@person_index)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    if form.start_year_2026_or_later?
      (2...@person_index).any? do |i|
        log["relat#{i}"] == "P"
      end
    else
      false
    end
  end
end
