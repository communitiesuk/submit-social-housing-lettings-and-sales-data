class Form::Sales::Questions::Buyer2AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age2_known"
    @check_answer_label = "Buyer 2’s age"
    @header = "Do you know buyer 2’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @summary_labels = SUMMARY_LABELS
    @page = page
    @conditional_for = {
      "age2" => [0],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  SUMMARY_LABELS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "Not known" },
  }.freeze
end
