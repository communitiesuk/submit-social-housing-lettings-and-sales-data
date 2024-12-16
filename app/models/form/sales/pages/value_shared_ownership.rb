class Form::Sales::Pages::ValueSharedOwnership < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @copy_key = "sales.sale_information.value"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
    ]
  end
end
