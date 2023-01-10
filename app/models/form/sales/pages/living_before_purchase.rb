class Form::Sales::Pages::LivingBeforePurchase < ::Form::Page
  def questions
    @questions ||= [
      Form::Sales::Questions::LivingBeforePurchase.new(nil, nil, self),
    ]
  end
end
