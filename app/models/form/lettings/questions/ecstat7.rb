class Form::Lettings::Questions::Ecstat7 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ecstat7"
    @check_answer_label = "Person 7’s working situation"
    @header = "Which of these best describes person 7’s working situation?"
    @type = "radio"
    @check_answers_card_number = 7
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "2" => { "value" => "Part-time – Less than 30 hours" }, "1" => { "value" => "Full-time – 30 hours or more" }, "7" => { "value" => "Full-time student" }, "3" => { "value" => "In government training into work, such as New Deal" }, "4" => { "value" => "Jobseeker" }, "6" => { "value" => "Not seeking work" }, "8" => { "value" => "Unable to work because of long term sick or disability" }, "5" => { "value" => "Retired" }, "9" => { "value" => "Child under 16", "depends_on" => [{ "age7_known" => 1 }, { "age7" => { "operator" => "<", "operand" => 16 } }] }, "0" => { "value" => "Other" }, "divider" => { "value" => true }, "10" => { "value" => "Tenant prefers not to say" } }.freeze
end
