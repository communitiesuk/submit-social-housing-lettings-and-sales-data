class Form::Lettings::Pages::AllocationSystem < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::LettingAllocation.new(nil, nil, self)]
  end
end
