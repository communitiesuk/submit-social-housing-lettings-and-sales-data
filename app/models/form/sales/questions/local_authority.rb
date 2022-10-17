class Form::Sales::Questions::LocalAuthority < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @check_answer_label = "Local authority"
    @header = "Which area is this property in?"
    @hint_text = "Where this property is located."
    @type = "select"
    @width = 10
    @page = page
  end
  #LAD11NM value mapping
  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?

    LocalAuthority.select(:id, :name).each_with_object(answer_opts) do |local_authority, hsh|
      hsh[local_authority.id] = local_authority.name
      hsh
    end
  end

  def displayed_answer_options(_log)
    answer_options
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def hidden_in_check_answers?(_log, current_user)
    !current_user.support?
  end

  def derived?
    true
  end
end
