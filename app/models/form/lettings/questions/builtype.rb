class Form::Lettings::Questions::Builtype < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "builtype"
    @check_answer_label = "Type of building"
    @header = "What type of building is the property?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 20
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Converted from previous residential or non-residential property" },
    "1" => { "value" => "Purpose built" },
  }.freeze
end
