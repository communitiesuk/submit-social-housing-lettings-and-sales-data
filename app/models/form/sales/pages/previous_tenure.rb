class Form::Sales::Pages::PreviousTenure < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "shared_ownership_previous_tenure"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "soctenant" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousTenure.new(nil, nil, self),
    ]
  end
end
