class Form::Lettings::Questions::SchemeId < ::Form::Question
  def initialize(_id, hsh, page)
    super("scheme_id", hsh, page)
    @check_answer_label = "Scheme name"
    @header = "What scheme is this log for?"
    @hint_text = "Enter scheme name or postcode"
    @type = "select"
    @answer_options = answer_options
    @guidance_position = GuidancePosition::BOTTOM
    @guidance_partial = "scheme_selection"
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?

    Scheme.select(:id, :service_name, :primary_client_group, :secondary_client_group).each_with_object(answer_opts) do |scheme, hsh|
      hsh[scheme.id.to_s] = scheme
      hsh
    end
  end

  def displayed_answer_options(lettings_log, _user = nil)
    organisation = lettings_log.owning_organisation || lettings_log.created_by&.organisation
    schemes = organisation ? Scheme.select(:id).where(owning_organisation_id: organisation.id, confirmed: true) : Scheme.select(:id).where(confirmed: true)
    filtered_scheme_ids = schemes.joins(:locations).merge(Location.where("startdate <= ? or startdate IS NULL", Time.zone.today)).map(&:id)
    answer_options.select do |k, _v|
      filtered_scheme_ids.include?(k.to_i) || k.blank?
    end
  end

  def hidden_in_check_answers?(lettings_log, _current_user = nil)
    !supported_housing_selected?(lettings_log)
  end

private

  def supported_housing_selected?(lettings_log)
    lettings_log.needstype == 2
  end

  def selected_answer_option_is_derived?(_lettings_log)
    false
  end
end
