class Form::Setup::Pages::TenancyStartDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_start_date"
    @description = ""
    @questions = questions
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::TenancyStartDate.new(nil, nil, self),
    ]
  end
end
