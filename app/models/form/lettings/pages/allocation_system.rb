class Form::Lettings::Pages::AllocationSystem < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "allocation_system"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::LettingAllocation.new(nil, nil, self)]
  end
end
