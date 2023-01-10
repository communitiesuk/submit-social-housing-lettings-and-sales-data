class Form::Sales::Questions::PropertyBuildingType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "builtype"
    @check_answer_label = "Type of building"
    @header = "What type of building is the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = ""
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Purpose built" },
    "2" => { "value" => "Converted from previous residential or non-residential property" },
  }.freeze
end
