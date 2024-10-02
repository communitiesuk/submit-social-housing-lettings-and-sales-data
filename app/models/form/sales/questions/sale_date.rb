class Form::Sales::Questions::SaleDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "saledate"
    @check_answer_label = I18n.t("forms.#{form.start_date.year}.sales.setup.saledate.check_answer_label")
    @header = I18n.t("forms.#{form.start_date.year}.sales.setup.saledate.question_text")
    @hint_text = I18n.t("forms.#{form.start_date.year}.sales.setup.saledate.hint_text")
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 1, 2024 => 3 }.freeze
end
