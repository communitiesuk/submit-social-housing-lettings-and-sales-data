class Form::Sales::Pages::GrantValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "grant_value_check"
    @depends_on = [
      {
        "grant_outside_common_range?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::GrantValueCheck.new(nil, nil, self),
    ]
  end
end
