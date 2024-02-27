class Form::Sales::Questions::NumberJointBuyers < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointmore"
    @check_answer_label = "More than 2 joint buyers"
    @header = "Are there more than 2 joint buyers of this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = 10
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def hint_text
    if form.start_year_after_2024?
      nil
    else
      "You should still try to answer all questions even if the buyer wasn't interviewed in person"
    end
  end
end
