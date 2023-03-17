class Form::Lettings::Questions::Armedforces < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "armedforces"
    @check_answer_label = "Household links to UK armed forces"
    @header = "Does anybody in the household have any links to the UK armed forces?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "This excludes national service.<br><br>If there are several people in the household with links to the UK armed forces, you should answer for the regular. If there’s no regular, answer for the reserve. If there’s no reserve, answer for the spouse or civil partner."
    @answer_options = ANSWER_OPTIONS
    @question_number = 66
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes – the person is a current or former regular" },
    "4" => { "value" => "Yes – the person is a current or former reserve" },
    "5" => { "value" => "Yes – the person is a spouse or civil partner of a UK armed forces member and has been bereaved or separated from them within the last 2 years" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Person prefers not to say" },
    "6" => { "value" => "Don’t know" },
  }.freeze
end
