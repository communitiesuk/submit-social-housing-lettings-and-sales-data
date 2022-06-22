class Form::Setup::Questions::OwningOrganisationId < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Owning organisation"
    @header = "Which organisation is the owning organisation for this log?"
    @hint_text = ""
    @type = "select"
    @page = page
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?

    Organisation.select(:id, :name).each_with_object(answer_opts) do |organisation, hsh|
      hsh[organisation.id] = organisation.name
      hsh
    end
  end

  def displayed_answer_options(case_log)
    return answer_options unless case_log.created_by

    ids = ["", case_log.created_by.organisation.id]
    answer_options.select { |k, _v| ids.include?(k) }
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def hidden_in_check_answers?(_case_log, current_user)
    !current_user.support?
  end

  def derived?
    true
  end
end
