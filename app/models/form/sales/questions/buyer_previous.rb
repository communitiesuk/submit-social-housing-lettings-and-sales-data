class Form::Sales::Questions::BuyerPrevious < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "soctenant"
    @check_answer_label = I18n.t("check_answer_labels.soctenant", count: joint_purchase ? 2 : 1)
    @header = I18n.t("questions.soctenant", count: joint_purchase ? 2 : 1)
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = 84
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "0" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    }
  end
end
