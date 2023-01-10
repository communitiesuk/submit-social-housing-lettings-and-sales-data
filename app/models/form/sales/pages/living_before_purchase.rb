class Form::Sales::Pages::LivingBeforePurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::LivingBeforePurchase.new(nil, nil, self),
    ]
  end
end
