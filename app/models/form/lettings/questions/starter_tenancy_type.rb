class Form::Lettings::Questions::StarterTenancyType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancy"
    @check_answer_label = "Type of main tenancy after the starter period has ended?"
    @header = "What is the type of tenancy after the starter period has ended?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "This is also known as an ‘introductory period’."
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
