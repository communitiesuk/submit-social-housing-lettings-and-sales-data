class Form::Lettings::Questions::TenancyOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancyother"
    @check_answer_label = ""
    @header = "Please state the tenancy type"
    @type = "text"
    @check_answers_card_number = 0
    @hint_text = ""
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 27 }.freeze
end
