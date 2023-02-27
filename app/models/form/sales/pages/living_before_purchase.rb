class Form::Sales::Pages::LivingBeforePurchase < ::Form::Page
  def initialize(id, hsh, form, question_number:)
    super(id, hsh, form)
    @question_number = question_number
  end

  def questions
    @questions ||= [
      living_before_purchase,
      Form::Sales::Questions::LivingBeforePurchaseYears.new(nil, nil, self),
    ].compact
  end

  def living_before_purchase
    if form.start_date.year >= 2023
      Form::Sales::Questions::LivingBeforePurchase.new(nil, nil, self, question_number: @question_number)
    end
  end
end
