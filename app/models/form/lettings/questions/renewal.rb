class Form::Lettings::Questions::Renewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "renewal"
    @check_answer_label = "Property renewal"
    @header = "Is this letting a renewal?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "A renewal is a letting to the same tenant in the same property"
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze
end
