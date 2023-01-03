class Form::Sales::Pages::PreviousBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_bedrooms"
    @header = "About the buyers’ previous property"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "soctenant" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousBedrooms.new(nil, nil, self),
    ]
  end
end
