class Form::Sales::Questions::LeaseholdChargesKnown < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "has_mscharge"
    @check_answer_label = "Monthly leasehold charges known?"
    @header = "Do you know the monthly leasehold charges for the property?"
    @hint_text = "For example, service and management charges"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "mscharge" => [1],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "has_mscharge" => 1,
        },
      ],
    }
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  def question_number
    case @ownershipsch
    when 1
      98
    when 2
      109
    when 3
      117
    end
  end
end
