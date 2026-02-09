class Form::Lettings::Questions::RsnvacFirstLet < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rsnvac"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "16" => { "value" => "First let of conversion, rehabilitation or acquired property" },
    "17" => { "value" => "First let of leased property" },
    "15" => { "value" => "First let of new-build property" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 15, 2024 => 16, 2025 => 13, 2026 => 13 }.freeze
end
