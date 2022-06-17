class Form::Setup::Questions::NeedsType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "needstype"
    @check_answer_label = "Needs type"
    @header = "What is the needs type?"
    @hint_text = ""
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "General needs" },
    "2" => { "value" => "Supported housing" },
  }.freeze
end
