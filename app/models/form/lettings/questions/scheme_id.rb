class Form::Lettings::Questions::SchemeId < ::Form::Question
  def initialize(_id, hsh, page)
    super("scheme_id", hsh, page)
    @type = "select"
    @answer_options = answer_options
    @top_guidance_partial = "finding_scheme"
    @bottom_guidance_partial = "scheme_selection"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR) if form.start_date.present?
    @inferred_answers = {
      "location.name": {
        "scheme_has_multiple_locations?": false,
      },
    }
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?

    Scheme.visible.select(:id, :service_name, :primary_client_group,
                          :secondary_client_group).each_with_object(answer_opts) do |scheme, hsh|
      hsh[scheme.id.to_s] = scheme
      hsh
    end
  end

  def displayed_answer_options(lettings_log, _user = nil)
    organisation = lettings_log.owning_organisation || lettings_log.assigned_to&.organisation
    schemes = if organisation
                Scheme.visible.includes(:locations).select(:id).where(owning_organisation_id: organisation.id,
                                                                      confirmed: true)
              else
                Scheme.visible.includes(:locations).select(:id).where(confirmed: true)
              end
    filtered_scheme_ids = schemes.joins(:locations).merge(Location.started_in_2_weeks).map(&:id)
    answer_options.select do |k, _v|
      filtered_scheme_ids.include?(k.to_i) || k.blank?
    end
  end

  def hidden_in_check_answers?(lettings_log, _current_user = nil)
    !supported_housing_selected?(lettings_log)
  end

  def get_extra_check_answer_value(lettings_log)
    lettings_log.form.get_question("postcode_full", nil).label_from_value(lettings_log.postcode_full) unless lettings_log.scheme_has_multiple_locations?
  end

private

  def supported_housing_selected?(lettings_log)
    lettings_log.needstype == 2
  end

  def selected_answer_option_is_derived?(_lettings_log)
    false
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 9, 2024 => 4, 2025 => 4, 2026 => 4 }.freeze
end
