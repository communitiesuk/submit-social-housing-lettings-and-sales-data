class Form::Lettings::Questions::Offered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "offered"
    @check_answer_label = I18n.t("check_answer_labels.offered")
    @header = I18n.t("questions.offered")
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @hint_text = I18n.t("hints.offered")
    @step = 1
    @question_number = 18
  end
end
