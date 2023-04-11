class Form::Lettings::Questions::PostcodeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_known"
    @check_answer_label = "Do you know the property postcode?"
    @header = "Do you know the property’s postcode?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @do_not_clear = true
    @conditional_for = { "postcode_full" => [1] }
    @hidden_in_check_answers = { "depends_on" => [{ "postcode_known" => 0 }, { "postcode_known" => 1 }] }
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze
end
