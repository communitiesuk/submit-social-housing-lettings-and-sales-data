class Form::Lettings::Questions::Age1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1"
    @check_answer_label = "Lead tenant’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age1_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = 1
    @max = 120
    @min = 16
    @step = 1
  end
end
