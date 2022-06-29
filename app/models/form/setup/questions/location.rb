class Form::Setup::Questions::Location < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "location"
    @check_answer_label = "Location"
    @header = "Which location used by is this log for?"
    @hint_text = ""
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @derived = true unless FeatureToggle.supported_housing_schemes_enabled?
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "General needs" },
    "2" => { "value" => "Supported housing" },
  }.freeze
end
