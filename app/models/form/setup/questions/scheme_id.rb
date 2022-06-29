class Form::Setup::Questions::SchemeId < ::Form::Question
  def initialize(id, hsh, page)
    super("scheme_id", hsh, page)
    @check_answer_label = "Scheme name"
    @header = "What scheme is this log for?"
    @hint_text = "Enter scheme name or postcode"
    @type = "select"
    @answer_options = answer_options
  end

  def answer_options
    answer_opts = {}
    return answer_opts unless ActiveRecord::Base.connected?
    Scheme.select(:id, :service_name).each_with_object(answer_opts) do |scheme, hsh|
      hsh[scheme.id] = scheme.service_name
      hsh
    end
  end

  def displayed_answer_options(case_log) 
    return {} unless case_log.created_by
    user_org_scheme_ids = Scheme.where("organisation_id = #{case_log.created_by.organisation_id}").map(&:id)
    answer_options.select { |k, _v| user_org_scheme_ids.include?(k) }
  end


private

  def selected_answer_option_is_derived?(_case_log)
    false
  end
end
