class Form::Setup::Questions::SchemeId < ::Form::Question
  def initialize(_id, hsh, page)
    super("scheme_id", hsh, page)
    @check_answer_label = "Scheme name"
    @header = "What scheme is this log for?"
    @hint_text = "Enter scheme name or postcode"
    @type = "select"
    @answer_options = answer_options
    @derived = true unless FeatureToggle.supported_housing_schemes_enabled?
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?

    Scheme.select(:id, :service_name, :primary_client_group, :secondary_client_group).each_with_object(answer_opts) do |scheme, hsh|
      hsh[scheme.id.to_s] = scheme
      hsh
    end
  end

  def displayed_answer_options(case_log)
    organisation = case_log.owning_organisation || case_log.created_by&.organisation
    schemes = organisation ? Scheme.select(:id).where(owning_organisation_id: organisation.id).where.not(managing_organisation_id: nil) : Scheme.select(:id).where.not(managing_organisation_id: nil)
    filtered_scheme_ids = schemes.joins(:locations).merge(Location.where("startdate <= ? or startdate IS NULL", Time.zone.today)).map(&:id)
    answer_options.select do |k, _v|
      filtered_scheme_ids.include?(k.to_i) || k.blank?
    end
  end

  def hidden_in_check_answers?(case_log, _current_user = nil)
    !supported_housing_selected?(case_log)
  end

  def answer_selected?(case_log, answer)
    case_log[id] == answer.name || case_log[id] == answer.resource
  end

private

  def supported_housing_selected?(case_log)
    case_log.needstype == 2
  end

  def selected_answer_option_is_derived?(_case_log)
    false
  end
end
