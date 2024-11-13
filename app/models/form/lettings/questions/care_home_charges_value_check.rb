class Form::Lettings::Questions::CareHomeChargesValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "carehome_charges_value_check"
    @copy_key = "lettings.soft_validations.care_home_charges_value_check"
    @type = "interruption_screen"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "carehome_charges_value_check" => 0 }, { "carehome_charges_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
