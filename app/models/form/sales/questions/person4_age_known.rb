class Form::Sales::Questions::Person4AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 4’s age known?"
    @header = "Do you know person 4’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = if id == "age5_known"
                         {
                           "age5" => [0],
                         }
                       else
                         {
                           "age6" => [0],
                         }
                       end
    @hidden_in_check_answers = if id == "age5_known"
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
                               else
                                 {
                                   "depends_on" => [
                                     {
                                       "age6_known" => 0,
                                     },
                                     {
                                       "age6_known" => 1,
                                     },
                                   ],
                                 }
                               end
    @check_answers_card_number = id == "age5_known" ? 5 : 6
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
