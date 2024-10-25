class Form::Lettings::Questions::Offered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "offered"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @hint_text = I18n.t("hints.offered")
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 18 }.freeze
end
