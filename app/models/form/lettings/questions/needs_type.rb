class Form::Lettings::Questions::NeedsType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "needstype"
    @check_answer_label = "Needs type"
    @header = "What is the needs type?"
    @hint_text = "General needs housing includes both self-contained and shared housing without support or specific adaptations. Supported housing can include direct access hostels, group homes, residential care and nursing homes."
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last) if form.start_date.present?
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "General needs" },
    "2" => { "value" => "Supported housing" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 3 }.freeze
end
