class Form::Lettings::Pages::ReasonablePreferenceReason < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "reasonable_preference_reason"
    @depends_on = [{ "reasonpref" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReasonablePreferenceReason.new(nil, nil, self)]
  end
end
