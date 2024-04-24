class Form::Lettings::Questions::GenderIdentity1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex1"
    @check_answer_label = I18n.t("forms.questions.#{form.start_date.year}.sex1.check_answer_label", default: "forms.questions.sex1.check_answer_label".to_sym)
    @header = I18n.t("forms.questions.#{form.start_date.year}.sex1.header")
    @type = "radio"
    @check_answers_card_number = 1
    @question_number = I18n.t("forms.questions.#{form.start_date.year}.sex1.question_number")
    @hint_text = I18n.t("forms.questions.#{form.start_date.year}.sex1.hint_text")
  end

  def answer_options
    {
      "F" => { "value" => I18n.t("forms.questions.#{form.start_date.year}.sex1.options.F") },
      "M" => { "value" => I18n.t("forms.questions.#{form.start_date.year}.sex1.options.M") },
      "X" => { "value" => I18n.t("forms.questions.#{form.start_date.year}.sex1.options.X") },
      "divider" => { "value" => true },
      "R" => { "value" => I18n.t("forms.questions.#{form.start_date.year}.sex1.options.R") },
    }
  end
end
