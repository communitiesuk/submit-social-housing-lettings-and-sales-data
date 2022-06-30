class Form::Setup::Questions::Location < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "location"
    @check_answer_label = "Location"
    @header = "Which location used by is this log for?"
    @hint_text = ""
    @type = "radio"
    @answer_options = location_answers
    @derived = true unless FeatureToggle.supported_housing_schemes_enabled?
    @page = page
  end

  def location_answers
    {}
  end

  def hidden_in_check_answers?(case_log, _current_user = nil)
    !supported_housing_selected?(case_log)
  end

  def supported_housing_selected?(case_log)
    case_log.needstype == 2
  end
end
