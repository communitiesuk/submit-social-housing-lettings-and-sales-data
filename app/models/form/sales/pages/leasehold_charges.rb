class Form::Sales::Pages::LeaseholdCharges < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
  end

  def copy_key
    if form.start_year_2025_or_later?
      case @ownershipsch
      when 1
        "sales.sale_information.leaseholdcharges.shared_ownership"
      when 2
        "sales.sale_information.leaseholdcharges.discounted_ownership"
      end
    else
      "sales.sale_information.leaseholdcharges"
    end
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HasLeaseholdCharges.new(nil, nil, self, ownershipsch: @ownershipsch),
      Form::Sales::Questions::LeaseholdCharges.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
