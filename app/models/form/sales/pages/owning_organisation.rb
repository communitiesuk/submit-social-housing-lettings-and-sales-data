class Form::Sales::Pages::OwningOrganisation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "owning_organisation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OwningOrganisationId.new(nil, nil, self),
    ]
  end

  def routed_to?(log, current_user)
    return false unless current_user
    return true if current_user.support?
    return true if has_multiple_stock_owners_with_own_stock?(current_user)

    stock_owners = current_user.organisation.stock_owners.where(holds_own_stock: true) + current_user.organisation.absorbed_organisations.where(holds_own_stock: true)

    if current_user.organisation.holds_own_stock?
      return true if current_user.organisation.absorbed_organisations.any?(&:holds_own_stock?)
      return true if stock_owners.count >= 1
      return false if log.owning_organisation == current_user.organisation

      log.update!(owning_organisation: current_user.organisation)
    else
      return false if stock_owners.count.zero?
      return true if stock_owners.count > 1
      return false if log.owning_organisation == stock_owners.first

      log.update!(owning_organisation: stock_owners.first)
    end

    false
  end

private

  def has_multiple_stock_owners_with_own_stock?(user)
    user.organisation.stock_owners.where(holds_own_stock: true).count > 1 || user.organisation.holds_own_stock? && user.organisation.stock_owners.where(holds_own_stock: true).count >= 1
  end
end
