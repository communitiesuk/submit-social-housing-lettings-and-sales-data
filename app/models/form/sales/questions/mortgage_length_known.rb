class Form::Sales::Questions::MortgageLengthKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortlen_known"
    @check_answer_label = "Mortgage length known"
    @header = "Do you know the mortgage length?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "mortlen" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "mortlen_known" => 0,
        },
        {
          "mortlen_known" => 1,
        },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
