class Form::Sales::Questions::BuyerStillServing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhregresstill"
    @type = "radio"
    @answer_options = answer_options
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    if form.start_year_2026_or_later?
      {
        "4" => { "value" => "Yes" },
        "5" => { "value" => "No - they left up to and including 2 years ago" },
        "6" => { "value" => "No - they left more than 2 years ago" },
        "divider" => { "value" => true },
        "9" => { "value" => "Don’t know" },
      }.freeze
    else
      {
        "4" => { "value" => "Yes" },
        "5" => { "value" => "No" },
        "6" => { "value" => "Buyer prefers not to say" },
        "divider" => { "value" => true },
        "7" => { "value" => "Don’t know" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 63, 2024 => 65, 2025 => 62, 2026 => 70 }.freeze
end
