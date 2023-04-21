class Form::Lettings::Questions::UprnKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_known"
    @check_answer_label = "UPRN known?"
    @header = "Do you know the property's UPRN?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "The Unique Property Reference Number (UPRN) is a unique number system created by Ordnance Survey and used by housing providers and sectors UK-wide. For example 10010457355.<br><br>
    You can continue without the UPRN, but it means we will need you to enter the address of the property."
    @conditional_for = { "uprn" => [1] }
    @inferred_check_answers_value = [
      {
        "condition" => { "uprn_known" => 0 },
        "value" => "Not known",
      },
    ]
    @hidden_in_check_answers = {
      "depends_on" => [
        { "uprn_known" => 0 },
        { "uprn_known" => 1 },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  def unanswered_error_message
    I18n.t("validations.property.uprn_known.invalid")
  end
end
