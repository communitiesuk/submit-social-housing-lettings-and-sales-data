class Form::Sales::Pages::Buyer2LivingIn < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_living_in"
    @depends_on = [{ "buyer_two_will_live_in_property?" => true }]
  end

  def questions
    @questions = [Form::Sales::Questions::Buyer2LivingIn.new(nil, nil, self)]
  end
end
