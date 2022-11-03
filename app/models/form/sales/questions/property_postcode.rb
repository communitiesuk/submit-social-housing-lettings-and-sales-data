class Form::Sales::Questions::PropertyPostcode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_known"
    @check_answer_label = "Do you know the property's postcode?"
    @header = "Do you know the property's postcode?"
    @hint_text = ""
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @width = 10
    @page = page
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "postcode_known" => 0,
        },
        {
          "postcode_known" => 1,
        },
      ],
    }

    @conditional_for = {
      "postcode_full" => [1],
    }
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze
end
