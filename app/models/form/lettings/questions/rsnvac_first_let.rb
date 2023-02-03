class Form::Lettings::Questions::RsnvacFirstLet < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rsnvac"
    @check_answer_label = "Vacancy reason"
    @header = "What is the reason for the property being vacant?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "16" =>
        { "value" => "First let of conversion, rehabilitation or acquired property" },
    "17" =>
  { "value" => "First let of leased property" },
    "15" =>
  { "value" => "First let of new-build property" },
  }.freeze
end
