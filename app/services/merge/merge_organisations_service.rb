class Merge::MergeOrganisationsService
  def initialize(absorbing_organisation_id:, merging_organisation_ids:, merge_date: Time.zone.today, absorbing_organisation_active_from_merge_date: false)
    @absorbing_organisation = Organisation.find(absorbing_organisation_id)
    @merging_organisations = Organisation.find(merging_organisation_ids)
    @merge_date = merge_date || Time.zone.today
    @absorbing_organisation_active_from_merge_date = absorbing_organisation_active_from_merge_date
  end

  def call
    ActiveRecord::Base.transaction do
      @merged_users = {}
      @merged_schemes = {}
      merge_organisation_details
      @merging_organisations.each do |merging_organisation|
        merge_rent_periods(merging_organisation)
        merge_organisation_relationships(merging_organisation)
        merge_users(merging_organisation)
        merge_schemes_and_locations(merging_organisation)
        merge_lettings_logs(merging_organisation)
        merge_sales_logs(merging_organisation)
        mark_organisation_as_merged(merging_organisation)
      end
      @absorbing_organisation.available_from = @merge_date if @absorbing_organisation_active_from_merge_date
      @absorbing_organisation.save!
      log_success_message
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Organisation merge failed with: #{e.message}")
      raise ActiveRecord::Rollback
    end
  end

private

  def merge_organisation_details
    @absorbing_organisation.holds_own_stock = merge_boolean_organisation_attribute("holds_own_stock")
  end

  def merge_rent_periods(merging_organisation)
    merging_organisation.rent_periods.each do |rent_period|
      @absorbing_organisation.organisation_rent_periods << OrganisationRentPeriod.new(rent_period:) unless @absorbing_organisation.rent_periods.include?(rent_period)
    end
  end

  def merge_organisation_relationships(merging_organisation)
    merging_organisation.parent_organisation_relationships.each do |parent_organisation_relationship|
      if parent_relationship_exists_on_absorbing_organisation?(parent_organisation_relationship)
        parent_organisation_relationship.destroy!
      else
        OrganisationRelationship.create!(parent_organisation: parent_organisation_relationship.parent_organisation, child_organisation: @absorbing_organisation)
      end
    end
    merging_organisation.child_organisation_relationships.each do |child_organisation_relationship|
      if child_relationship_exists_on_absorbing_organisation?(child_organisation_relationship)
        child_organisation_relationship.destroy!
      else
        OrganisationRelationship.create!(parent_organisation: @absorbing_organisation, child_organisation: child_organisation_relationship.child_organisation)
      end
    end
  end

  def merge_users(merging_organisation)
    @merged_users[merging_organisation.name] = merging_organisation.users.map { |user| { name: user.name, email: user.email } }
    merging_organisation.users.update_all(organisation_id: @absorbing_organisation.id)
  end

  def merge_schemes_and_locations(merging_organisation)
    @merged_schemes[merging_organisation.name] = []
    merging_organisation.owned_schemes.each do |scheme|
      next if scheme.deactivated?

      new_scheme = Scheme.create!(scheme.attributes.except("id", "owning_organisation_id", "old_id", "old_visible_id").merge(owning_organisation: @absorbing_organisation))
      scheme.locations.each do |location|
        next if location.deactivated?

        new_scheme.locations << Location.new(location.attributes.except("id", "scheme_id", "old_id", "old_visible_id"))
        LocationDeactivationPeriod.create!(location:, deactivation_date: @merge_date)
      end
      @merged_schemes[merging_organisation.name] << { name: new_scheme.service_name, code: new_scheme.id }
      SchemeDeactivationPeriod.create!(scheme:, deactivation_date: @merge_date)
    end
  end

  def merge_lettings_logs(merging_organisation)
    merging_organisation.owned_lettings_logs.after_date(@merge_date.to_time).each do |lettings_log|
      if lettings_log.scheme.present?
        scheme_to_set = @absorbing_organisation.owned_schemes.find_by(service_name: lettings_log.scheme.service_name)
        location_to_set = scheme_to_set.locations.find_by(name: lettings_log.location&.name, postcode: lettings_log.location&.postcode)

        lettings_log.scheme = scheme_to_set if scheme_to_set.present?
        lettings_log.location = location_to_set if location_to_set.present?
      end
      lettings_log.owning_organisation = @absorbing_organisation
      lettings_log.save!(validate: false)
    end
    merging_organisation.managed_lettings_logs.after_date(@merge_date.to_time).each do |lettings_log|
      lettings_log.managing_organisation = @absorbing_organisation
      lettings_log.save!(validate: false)
    end
  end

  def merge_sales_logs(merging_organisation)
    merging_organisation.sales_logs.after_date(@merge_date.to_time).each do |sales_log|
      sales_log.owning_organisation = @absorbing_organisation
      sales_log.save!(validate: false)
    end
  end

  def mark_organisation_as_merged(merging_organisation)
    merging_organisation.update(merge_date: @merge_date, absorbing_organisation: @absorbing_organisation)
  end

  def log_success_message
    @merged_users.each do |organisation_name, users|
      Rails.logger.info("Merged users from #{organisation_name}:")
      users.each do |user|
        Rails.logger.info("\t#{user[:name]} (#{user[:email]})")
      end
    end
    @merged_schemes.each do |organisation_name, schemes|
      Rails.logger.info("New schemes from #{organisation_name}:")
      schemes.each do |scheme|
        Rails.logger.info("\t#{scheme[:name]} (S#{scheme[:code]})")
      end
    end
  end

  def merge_boolean_organisation_attribute(attribute)
    @absorbing_organisation[attribute] ||= @merging_organisations.any? { |merging_organisation| merging_organisation[attribute] }
  end

  def parent_relationship_exists_on_absorbing_organisation?(parent_organisation_relationship)
    parent_organisation_relationship.parent_organisation == @absorbing_organisation || @merging_organisations.include?(parent_organisation_relationship.parent_organisation) || @absorbing_organisation.parent_organisation_relationships.where(parent_organisation: parent_organisation_relationship.parent_organisation).exists?
  end

  def child_relationship_exists_on_absorbing_organisation?(child_organisation_relationship)
    child_organisation_relationship.child_organisation == @absorbing_organisation || @merging_organisations.include?(child_organisation_relationship.child_organisation) || @absorbing_organisation.child_organisation_relationships.where(child_organisation: child_organisation_relationship.child_organisation).exists?
  end
end
