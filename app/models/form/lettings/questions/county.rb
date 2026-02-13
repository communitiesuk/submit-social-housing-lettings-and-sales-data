class Form::Lettings::Questions::County < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "county"
    @copy_key = "lettings.property_information.address.county"
    @type = "text"
    @plain_label = true
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @hide_question_number_on_page = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 12, 2024 => 13, 2025 => 17, 2026 => 17 }.freeze
end
