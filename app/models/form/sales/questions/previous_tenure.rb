class Form::Sales::Questions::PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "socprevten"
    @check_answer_label = "Previous property tenure"
    @header = "What was the previous tenure of the buyer?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Social Rent" },
    "2" => { "value" => "Affordable Rent" },
    "3" => { "value" => "London Affordable Rent" },
    "9" => { "value" => "Other" },
    "10" => { "value" => "Don’t know" },
  }.freeze
end
