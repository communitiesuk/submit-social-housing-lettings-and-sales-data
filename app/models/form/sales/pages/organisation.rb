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

  def routed_to?(log, current_user)
    return false unless current_user
    return true if current_user.support?

    stock_owners = current_user.organisation.stock_owners + current_user.organisation.absorbed_organisations.where(holds_own_stock: true)

    if current_user.organisation.holds_own_stock?
      if current_user.organisation.absorbed_organisations.any?(&:holds_own_stock?)
        return true
      end
      return true if stock_owners.count >= 1

      log.update!(owning_organisation: current_user.organisation)
    else
      return false if stock_owners.count.zero?
      return true if stock_owners.count > 1

      log.update!(owning_organisation: stock_owners.first)
    end

    false
  end
end
