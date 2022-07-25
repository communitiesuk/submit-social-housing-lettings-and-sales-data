class Form::Setup::Questions::LocationId < ::Form::Question
  def initialize(_id, hsh, page)
    super("location_id", hsh, page)
    @check_answer_label = "Location"
    @header = "Which location is this log for?"
    @hint_text = ""
    @type = "radio"
    @extra_check_answer_value = "location_admin_district"
    @answer_options = answer_options
    @inferred_answers = {
      "location.name": {
        "needstype": 2,
      },
    }
  end

  def answer_options
    answer_opts = {}
    return answer_opts unless ActiveRecord::Base.connected?

    Location.select(:id, :postcode, :name).where("startdate <= ? or startdate IS NULL", Time.zone.today).each_with_object(answer_opts) do |location, hsh|
      hsh[location.id.to_s] = { "value" => location.postcode, "hint" => location.name }
      hsh
    end
  end

  def displayed_answer_options(case_log)
    return {} unless case_log.scheme

    scheme_location_ids = case_log.scheme.locations.pluck(:id)
    answer_options.select { |k, _v| scheme_location_ids.include?(k.to_i) }
  end

  def hidden_in_check_answers?(case_log, _current_user = nil)
    !supported_housing_selected?(case_log)
  end

private

  def supported_housing_selected?(case_log)
    case_log.needstype == 2
  end

  def selected_answer_option_is_derived?(_case_log)
    false
  end
end
