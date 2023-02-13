class Form::Sales::Pages::NumberOfOthersInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "number_of_others_in_property"
    @depends_on = [
      {
        "privacynotice" => 1,
        "jointpur" => 2,
      },
      {
        "noint" => 1,
        "jointpur" => 2,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::NumberOfOthersInProperty.new(nil, nil, self, joint_purchase: false),
    ]
  end
end
