class Form::Sales::Questions::Person3AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 3’s age known?"
    @header = "Do you know person 3’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = if id == "age4_known"
                         {
                           "age4" => [0],
                         }
                       else
                         {
                           "age5" => [0],
                         }
                       end
    @hidden_in_check_answers = if id == "age4_known"
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
                               else
                                 {
                                   "depends_on" => [
                                     {
                                       "age5_known" => 0,
                                     },
                                     {
                                       "age5_known" => 1,
                                     },
                                   ],
                                 }
                               end
    @check_answers_card_number = id == "age4_known" ? 4 : 5
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
