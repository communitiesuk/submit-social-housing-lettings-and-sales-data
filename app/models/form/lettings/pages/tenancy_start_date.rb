class Form::Lettings::Pages::TenancyStartDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_start_date"
    @description = ""
    @subsection = subsection
    @next_unresolved_page_id = "scheme"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::TenancyStartDate.new(nil, nil, self),
    ]
  end
end
