class Form::Sales::Questions::PreviousLaKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "previous_la_known"
    @check_answer_label = "Local authority of buyer 1’s last settled accommodation"
    @header = "Do you know the local authority of buyer 1’s last settled accommodation?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = "This is also known as the household’s 'last settled home'"
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "previous_la_known" => 0,
        },
        {
          "previous_la_known" => 1,
        },
      ],
    }
    @conditional_for = {
      "prevloc" => [1],
    }
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze
end
