class Form::Sales::Questions::PropertyPostcode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pcodenk"
    @check_answer_label = "Postcode"
    @header = "Do you know the property's postcode?"
    @hint_text = ""
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @width = 10
    @page = page

    @conditional_for = {
      "postcode_full" => [0],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end

#"sales-log-postcode-full-field"
