class Form::Setup::Questions::LocationId < ::Form::Question
  def initialize(_id, hsh, page)
    super("location_id", hsh, page)
    @check_answer_label = "Location"
    @header = "Which location is this log for?"
    @hint_text = ""
    @type = "radio"
    @derived = true unless FeatureToggle.supported_housing_schemes_enabled?
    @answer_options = answer_options
  end

  def answer_options
    answer_opts = {}
    return answer_opts unless ActiveRecord::Base.connected?

    Location.select(:id, :postcode, :address_line1).each_with_object(answer_opts) do |location, hsh|
      hsh[location.id.to_s] = { "value" => location.postcode, "hint" => location.address_line1 }
      hsh
    end
  end

  def displayed_answer_options(case_log)
    return {} unless case_log.scheme

    scheme_location_ids = Location.where(scheme_id: case_log.scheme.id).map(&:id).map(&:to_s)
    answer_options.select { |k, _v| scheme_location_ids.include?(k) }
  end

  def hidden_in_check_answers?(case_log, _current_user = nil)
    !supported_housing_selected?(case_log)
  end

private

  def supported_housing_selected?(case_log)
    case_log.needstype == 2
  end
end
