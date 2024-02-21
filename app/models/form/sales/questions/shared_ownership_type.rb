class Form::Sales::Questions::SharedOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @check_answer_label = "Type of shared ownership sale"
    @header = "What is the type of shared ownership sale?"
    @top_guidance_partial = guidance_partial
    @type = "radio"
    @answer_options = answer_options
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  def hint_text
    if form.start_year_after_2024?
      "When the purchaser buys an initial share of up to 75% of the property value and pays rent to the Private Registered Provider (PRP) on the remaining portion, or a subsequent staircasing transaction"
    else
      "A shared ownership sale is when the purchaser buys up to 75% of the property value and pays rent to the Private Registered Provider (PRP) on the remaining portion"
    end
  end

  def answer_options
    if form.start_date.year >= 2023
      {
        "2" => { "value" => "Shared Ownership (old model lease)" },
        "30" => { "value" => "Shared Ownership (new model lease)" },
        "18" => { "value" => "Social HomeBuy — shared ownership purchase" },
        "16" => { "value" => "Home Ownership for people with Long-Term Disabilities (HOLD)" },
        "24" => { "value" => "Older Persons Shared Ownership" },
        "28" => { "value" => "Rent to Buy — Shared Ownership" },
        "31" => { "value" => "Right to Shared Ownership (RtSO)" },
        "32" => { "value" => "London Living Rent — Shared Ownership" },
      }
    else
      {
        "2" => { "value" => "Shared Ownership" },
        "24" => { "value" => "Old Persons Shared Ownership" },
        "18" => { "value" => "Social HomeBuy (shared ownership purchase)" },
        "16" => { "value" => "Home Ownership for people with Long-Term Disabilities (HOLD)" },
        "28" => { "value" => "Rent to Buy - Shared Ownership" },
        "31" => { "value" => "Right to Shared Ownership" },
        "30" => { "value" => "Shared Ownership - 2021 model lease" },
      }
    end
  end

  def guidance_partial
    if form.start_year_after_2024?
      "shared_ownership_type_definitions_2024"
    elsif form.start_date.year >= 2023
      "shared_ownership_type_definitions"
    end
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 4, 2024 => 6 }.freeze
end
