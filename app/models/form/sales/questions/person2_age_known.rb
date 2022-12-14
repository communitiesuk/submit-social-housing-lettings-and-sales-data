class Form::Sales::Questions::Person2AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 2’s age known?"
    @header = "Do you know person 2’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = if id == "age3_known"
                         {
                           "age3" => [0],
                         }
                       else
                         {
                           "age4" => [0],
                         }
                       end
    @hidden_in_check_answers = if id == "age3_known"
                                 {
                                   "depends_on" => [
                                     {
                                       "age3_known" => 0,
                                     },
                                     {
                                       "age3_known" => 1,
                                     },
                                   ],
                                 }
                               else
                                 {
                                   "depends_on" => [
                                     {
                                       "age4_known" => 0,
                                     },
                                     {
                                       "age4_known" => 1,
                                     },
                                   ],
                                 }
                               end
    @check_answers_card_number = id == "age3_known" ? 3 : 4
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
