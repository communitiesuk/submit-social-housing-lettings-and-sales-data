class Form::Setup::Questions::CreatedById < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "created_by_id"
    @check_answer_label = "User"
    @header = "Which user are you creating this log for?"
    @hint_text = ""
    @type = "select"
    @derived = true
    @page = page
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?

    User.select(:id, :name).each_with_object(answer_opts) do |user, hsh|
      hsh[user.id] = user.name
      hsh
    end
  end

  def displayed_answer_options(case_log)
    return answer_options unless case_log.owning_organisation

    user_ids = case_log.owning_organisation.users.pluck(:id) + [""]
    answer_options.select { |k, _v| user_ids.include?(k) }
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def hidden_in_check_answers
    !form.current_user.support?
  end
end
