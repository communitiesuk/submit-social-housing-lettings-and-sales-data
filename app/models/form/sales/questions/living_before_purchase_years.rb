class Form::Sales::Questions::LivingBeforePurchaseYears < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "proplen"
    @check_answer_label = "Number of years living in the property before purchase"
    @header = header_text
    @hint_text = hint_text
    @type = "numeric"
    @min = 0
    @max = 80
    @step = 1
    @width = 5
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def header_text
    if form.start_date.year >= 2023
      "How long did they live there?"
    else
      "How long did the buyer(s) live in the property before purchase?"
    end
  end

  def hint_text
    if form.start_date.year >= 2023
      "You should round up to the nearest year"
    else
      "You should round this up to the nearest year. If the buyers haven't been living in the property, enter '0'"
    end
  end

  def suffix_label(log)
    " #{'year'.pluralize(log[id])}"
  end

  QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 75, 2 => 99 },
    2024 => { 1 => 77, 2 => 101 },
  }.freeze
end
