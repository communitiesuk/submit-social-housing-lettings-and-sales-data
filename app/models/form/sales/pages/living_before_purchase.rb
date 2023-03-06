class Form::Sales::Pages::LivingBeforePurchase < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
  end
  def questions
    @questions ||= [
      living_before_purchase,
      Form::Sales::Questions::LivingBeforePurchaseYears.new(nil, nil, self, ownershipsch: @ownershipsch),
    ].compact
  end

  def living_before_purchase
    if form.start_date.year >= 2023
      Form::Sales::Questions::LivingBeforePurchase.new(nil, nil, self, ownershipsch: @ownershipsch)
    end
  end
end
