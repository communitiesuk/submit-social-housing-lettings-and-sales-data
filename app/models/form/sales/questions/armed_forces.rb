class Form::Sales::Questions::ArmedForces < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhregres"
    @check_answer_label = "Have any of the buyers ever served as a regular in the UK armed forces?"
    @header = "Have any of the buyers ever served as a regular in the UK armed forces?"
    @type = "radio"
    @hint_text = "A regular is somebody who has served in the Royal Navy, the Royal Marines, the Royal Airforce or Army full time and does not include reserve forces"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "7" => { "value" => "No" },
    "3" => { "value" => "Buyer prefers not to say" },
    "8" => { "value" => "Don't know" },
  }.freeze
end
