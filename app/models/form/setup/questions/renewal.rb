class Form::Setup::Questions::Renewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "renewal"
    @check_answer_label = "Property renewal"
    @header = "Is this letting a renewal?"
    @hint_text = ""
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze
end
