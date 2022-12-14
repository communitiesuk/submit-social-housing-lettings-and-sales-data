class Form::Sales::Questions::Person1Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 1’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = hsh[:inferred_check_answers_value]
    @hidden_in_check_answers = hsh[:hidden_in_check_answers]
    @check_answers_card_number = hsh[:check_answers_card_number]
  end
end
