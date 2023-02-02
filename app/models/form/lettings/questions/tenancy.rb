class Form::Lettings::Questions::Tenancy < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancy"
    @check_answer_label = "Type of main tenancy"
    @header = "What is the type of tenancy?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "tenancyother" => [3] }
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "Assured Shorthold Tenancy (AST) – Fixed term" },
    "6" => { "value" => "Secure – fixed term" },
    "2" => { "value" => "Assured – lifetime" },
    "7" => { "value" => "Secure – lifetime" },
    "5" => { "value" => "Licence agreement" },
    "3" => { "value" => "Other" },
  }.freeze
end
