class Form::Sales::Questions::LeaseholdChargesKnown < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "mscharge_known"
    @check_answer_label = "Monthly leasehold charges known?"
    @header = "#{question_number} - Does the property have any monthly leasehold charges?"
    @hint_text = "For example, service and management charges"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "mscharge" => [1],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "mscharge_known" => 1,
        },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze
end
