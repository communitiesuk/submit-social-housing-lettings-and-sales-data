class Form::Sales::Questions::Buyer1EthnicBackgroundAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Buyer 1’s ethnic background"
    @header = "Which of the following best describes the buyer 1’s Asian or Asian British background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Bangladeshi" },
    "15" => { "value" => "Chinese" },
    "8" => { "value" => "Indian" },
    "9" => { "value" => "Pakistani" },
    "11" => { "value" => "Any other Asian or Asian British background" },
  }.freeze
end
