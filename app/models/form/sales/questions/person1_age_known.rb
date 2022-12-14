class Form::Sales::Questions::Person1AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 1’s age known?"
    @header = "Do you know person 1’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = if id == "age2_known"
                         {
                           "age2" => [0],
                         }
                       else
                         {
                           "age3" => [0],
                         }
                       end
    @hidden_in_check_answers = if id == "age2_known"
                                 {
                                   "depends_on" => [
                                     {
                                       "age2_known" => 0,
                                     },
                                     {
                                       "age2_known" => 1,
                                     },
                                   ],
                                 }
                               else
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
                               end
    @check_answers_card_number = id == "age2_known" ? 2 : 3
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
