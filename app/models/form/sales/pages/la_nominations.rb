class Form::Sales::Pages::LaNominations < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "la_nominations"
    @copy_key = "sales.sale_information.la_nominations"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::LaNominations.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user)
    return false if log.staircase == 1 && form.start_year_2024_or_later?

    super
  end
end
