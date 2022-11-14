class Form::Lettings::Questions::HousingProvider < ::Form::Question
  attr_accessor :current_user, :log

  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Housing provider"
    @header = "Which organisation owns this property?"
    @type = "select"
    @page = page
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless current_user

    if !current_user.support? && current_user.organisation.holds_own_stock?
      answer_opts[current_user.organisation.id] = "#{current_user.organisation.name} (Your organisation)"
    end

    housing_providers.select(:id, :name).each_with_object(answer_opts) do |organisation, hsh|
      hsh[organisation.id] = organisation.name
      hsh
    end
  end

  def displayed_answer_options(log, user = nil)
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

    # Hide when less than 2 housing providers
    housing_providers.count < 2
  end

  def enabled
    true
  end

private

  def selected_answer_option_is_derived?(_log)
    true
  end

  def housing_providers
    @housing_providers ||= if current_user.support?
                             Organisation.all
                           else
                             current_user.organisation.housing_providers
                           end
  end
end
