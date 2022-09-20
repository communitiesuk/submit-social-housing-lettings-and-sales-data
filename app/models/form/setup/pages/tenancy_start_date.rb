class Form::Setup::Pages::TenancyStartDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_start_date"
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Setup::Questions::TenancyStartDate.new(nil, nil, self),
    ]
  end
end
