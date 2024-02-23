class Form::Lettings::Questions::PropertyReference < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "propcode"
    @check_answer_label = "Property reference"
    @header = "What is the property reference?"
    @hint_text = "This is how you usually refer to this property on your own systems."
    @type = "text"
    @width = 10
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last) if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 8, 2024 => 10 }.freeze
end
