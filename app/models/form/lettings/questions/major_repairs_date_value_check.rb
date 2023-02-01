class Form::Lettings::Questions::MajorRepairsDateValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "major_repairs_date_value_check"
    @check_answer_label = "Major repairs date confirmation"
    @header = "Are you sure the property has been vacant for this long?"
    @type = "interruption_screen"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "major_repairs_date_value_check" => 0 }, { "major_repairs_date_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
