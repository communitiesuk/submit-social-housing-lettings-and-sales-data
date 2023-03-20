class Form::Lettings::Questions::Tshortfall < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tshortfall"
    @check_answer_label = "Estimated outstanding amount"
    @header = "Estimated outstanding amount"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @prefix = "£"
    @suffix = [
      { "label" => " every 2 weeks", "depends_on" => { "period" => 2 } },
      { "label" => " every 4 weeks", "depends_on" => { "period" => 3 } },
      { "label" => " every calendar month", "depends_on" => { "period" => 4 } },
      { "label" => " every week for 50 weeks", "depends_on" => { "period" => 5 } },
      { "label" => " every week for 49 weeks", "depends_on" => { "period" => 6 } },
      { "label" => " every week for 48 weeks", "depends_on" => { "period" => 7 } },
      { "label" => " every week for 47 weeks", "depends_on" => { "period" => 8 } },
      { "label" => " every week for 46 weeks", "depends_on" => { "period" => 9 } },
      { "label" => " every week for 52 weeks", "depends_on" => { "period" => 1 } },
    ]
    @question_number = 100
  end
end
