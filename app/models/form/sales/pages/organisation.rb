class Form::Sales::Pages::Organisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "organisation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OwningOrganisationId.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, current_user)
    return false unless current_user
    return true if current_user.support?

    absorbed_stock_owners = current_user.organisation.absorbed_organisations.where(holds_own_stock: true)

    if current_user.organisation.holds_own_stock?
      return true if absorbed_stock_owners.count >= 1
    else
      return false if absorbed_stock_owners.count.zero?
      return true if absorbed_stock_owners.count > 1
    end

    false
  end
end
