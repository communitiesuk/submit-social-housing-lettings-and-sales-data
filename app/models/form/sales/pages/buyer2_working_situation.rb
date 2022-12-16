class Form::Sales::Pages::Buyer2WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_working_situation"
    @depends_on = [{
      "jointpur" => 1,
      "privacynotice" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2WorkingSituation.new(nil, nil, self),
    ]
  end
end
