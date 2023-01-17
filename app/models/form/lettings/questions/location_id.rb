class Form::Lettings::Questions::LocationId < ::Form::Question
  def initialize(_id, hsh, page)
    super("location_id", hsh, page)
    @check_answer_label = "Location"
    @header = "Which location is this log for?"
    @type = "radio"
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

  def displayed_answer_options(lettings_log, _user = nil)
    return {} unless lettings_log.scheme

    scheme_location_ids = lettings_log.scheme.locations.pluck(:id)
    answer_options.select { |k, _v| scheme_location_ids.include?(k.to_i) }
  end

  def hidden_in_check_answers?(lettings_log, _current_user = nil)
    !supported_housing_selected?(lettings_log)
  end

  def get_extra_check_answer_value(lettings_log)
    lettings_log.form.get_question("la", nil).label_from_value(lettings_log.la)
  end

private

  def supported_housing_selected?(lettings_log)
    lettings_log.needstype == 2
  end

  def selected_answer_option_is_derived?(_lettings_log)
    false
  end
end
