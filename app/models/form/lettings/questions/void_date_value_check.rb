class Form::Lettings::Questions::VoidDateValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "void_date_value_check"
    @copy_key = "lettings.soft_validations.void_date_value_check"
    @type = "interruption_screen"
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "void_date_value_check" => 0 }, { "void_date_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
