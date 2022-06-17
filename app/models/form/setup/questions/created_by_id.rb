class Form::Setup::Questions::CreatedById < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "created_by_id"
    @check_answer_label = "User"
    @header = "Which user are you creating this log for?"
    @hint_text = ""
    @type = "select"
    @page = page
    @answer_options = answer_options_values
  end

  def answer_options_values
    answer_opts = { "" => "Select an option" }
    User.all.each_with_object(answer_opts) do |user, hsh|
      hsh[user.id] = user.name
      hsh
    end
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def hidden_in_check_answers
    !form.current_user.support?
  end
end
