class Form::Sales::Pages::ValueSharedOwnership < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "value_shared_ownership"
    @header = "About the price of the property"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
    ]
  end
end
