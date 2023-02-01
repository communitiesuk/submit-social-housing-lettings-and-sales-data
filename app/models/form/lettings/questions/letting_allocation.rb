class Form::Lettings::Questions::LettingAllocation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "letting_allocation"
    @check_answer_label = "Allocation system"
    @header = "How was this letting allocated?"
    @type = "checkbox"
    @check_answers_card_number = 0
    @hint_text = "Select all that apply."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "cbl" => { "value" => "Choice-based lettings (CBL)" }, "cap" => { "value" => "Common Allocation Policy (CAP)" }, "chr" => { "value" => "Common housing register (CHR)" }, "divider" => { "value" => true }, "letting_allocation_unknown" => { "value" => "None of these allocation systems" } }.freeze
end
