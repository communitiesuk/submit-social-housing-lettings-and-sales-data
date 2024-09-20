class OrganisationPolicy
  attr_reader :user, :organisation

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
  end

  def deactivate?
    user.support? && organisation.status == :active
  end

  def reactivate?
    user.support? && organisation.status == :deactivated
  end

  def delete_confirmation?
    delete?
  end

  def delete?
    return false unless user.support?
    return false unless organisation.status == :deactivated || organisation.status == :merged

    !has_any_logs_in_editable_collection_period
  end

  def has_any_logs_in_editable_collection_period
    editable_from_date = FormHandler.instance.earliest_open_for_editing_collection_start_date
    editable_lettings_logs = organisation.lettings_logs.visible.after_date(editable_from_date)

    return true if organisation.lettings_logs.visible.where(startdate: nil).any? || editable_lettings_logs.any?

    editable_sales_logs = organisation.sales_logs.visible.after_date(editable_from_date)
    organisation.sales_logs.visible.where(saledate: nil).any? || editable_sales_logs.any?
  end

  def duplicate_schemes?
    user.support? || (user.data_coordinator? && user.organisation == organisation)
  end
end
