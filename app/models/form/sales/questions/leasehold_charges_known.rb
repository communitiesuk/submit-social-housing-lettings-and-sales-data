class Form::Sales::Questions::LeaseholdChargesKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mscharge_known"
    @check_answer_label = "Monthly rent"
    @header = "Does the property have any monthly leasehold charges?"
    @hint_text = "For example, service and management charges"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @conditional_for = {
      "mscharge" => [1],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "mscharge_known" => 0,
        },
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
