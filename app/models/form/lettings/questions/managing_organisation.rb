class Form::Lettings::Questions::ManagingOrganisation < ::Form::Question
  attr_accessor :current_user, :log

  def initialize(id, hsh, page)
    super
    @id = "managing_organisation_id"
    @check_answer_label = "Managing agent"
    @header = "Which organisation manages this letting?"
    @type = "select"
    @answer_options = answer_options
    @page = page
  end

  def answer_options
    opts = { "" => "Select an option" }
    return opts unless ActiveRecord::Base.connected?
    return opts unless current_user
    return opts unless log

    if current_user.support?
      if log.owning_organisation.holds_own_stock?
        opts[log.owning_organisation.id] = "#{log.owning_organisation.name} (Owning organisation)"
      end
    else
      opts[current_user.organisation.id] = "#{current_user.organisation.name} (Your organisation)"
    end

    opts.merge(managing_organisations_answer_options)
  end

  def displayed_answer_options(log, user)
    @current_user = user
    @log = log

    answer_options
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def derived?
    true
  end

  def hidden_in_check_answers?(_log, user = nil)
    @current_user = user

    return false unless @current_user
    return false if @current_user.support?

    managing_organisations_answer_options.count < 2
  end

  def enabled
    true
  end

private

  def selected_answer_option_is_derived?(_log)
    true
  end

  def managing_organisations_answer_options
    if current_user.support?
      log.owning_organisation
    else
      current_user.organisation
    end.managing_agents.pluck(:id, :name).to_h
  end
end
