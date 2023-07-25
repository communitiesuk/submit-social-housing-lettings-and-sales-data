class Merge::MergeOrganisationsService
  def initialize(absorbing_organisation_id:, merging_organisation_ids:)
    @absorbing_organisation = Organisation.find(absorbing_organisation_id)
    @merging_organisations = Organisation.find(merging_organisation_ids)
  end

  def call
    merge_organisation_details
    merge_rent_periods
    merge_organisation_relationships
    merge_users
    merge_schemes_and_locations
    merge_lettings_logs
    mark_organisations_as_merged
    @absorbing_organisation.save!
  end

private

  def merge_organisation_details
    @absorbing_organisation.holds_own_stock = merge_boolean_organisation_attribute("holds_own_stock")
  end

  def merge_rent_periods
    @merging_organisations.each do |merging_organisation|
      merging_organisation.rent_periods.each do |rent_period|
        @absorbing_organisation.organisation_rent_periods << OrganisationRentPeriod.new(rent_period:) unless @absorbing_organisation.rent_periods.include?(rent_period)
      end
    end
  end

  def merge_organisation_relationships
    @merging_organisations.each do |merging_organisation|
      merging_organisation.parent_organisation_relationships.each do |parent_organisation_relationship|
        if parent_relationship_exists_on_absorbing_organisation?(parent_organisation_relationship)
          parent_organisation_relationship.destroy!
        else
          parent_organisation_relationship.update!(child_organisation: @absorbing_organisation)
        end
      end
      merging_organisation.child_organisation_relationships.each do |child_organisation_relationship|
        if child_relationship_exists_on_absorbing_organisation?(child_organisation_relationship)
          child_organisation_relationship.destroy!
        else
          child_organisation_relationship.update!(parent_organisation: @absorbing_organisation)
        end
      end
    end
  end

  def merge_users
    @merging_organisations.each do |merging_organisation|
      merging_organisation.users.update_all(organisation_id: @absorbing_organisation.id)
    end
  end

  def merge_schemes_and_locations
    @merging_organisations.each do |merging_organisation|
      merging_organisation.owned_schemes.each do |scheme|
        next if scheme.deactivated?

        new_scheme = Scheme.create!(scheme.attributes.except("id", "owning_organisation_id").merge(owning_organisation: @absorbing_organisation))
        scheme.locations.each do |location|
          new_scheme.locations << Location.new(location.attributes.except("id", "scheme_id")) unless location.deactivated?
        end
        SchemeDeactivationPeriod.create!(scheme:, deactivation_date: Time.zone.now)
      end
    end
  end

  def merge_lettings_logs
    @merging_organisations.each do |merging_organisation|
      merging_organisation.owned_lettings_logs.after_date(Time.zone.today).each do |lettings_log|
        if lettings_log.scheme.present?
          scheme_to_set = @absorbing_organisation.owned_schemes.find_by(service_name: lettings_log.scheme.service_name)
          location_to_set = scheme_to_set.locations.find_by(name: lettings_log.location&.name, postcode: lettings_log.location&.postcode)

          lettings_log.scheme = scheme_to_set if scheme_to_set.present?
          lettings_log.location = location_to_set if location_to_set.present?
        end
        lettings_log.owning_organisation = @absorbing_organisation
        lettings_log.save!
      end
      merging_organisation.managed_lettings_logs.after_date(Time.zone.today).each do |lettings_log|
        lettings_log.managing_organisation = @absorbing_organisation
        lettings_log.save!
      end
    end
  end

  def mark_organisations_as_merged
    # @merging_organisations.update_all(merge_date: Time.zone.today)
  end

  def merge_boolean_organisation_attribute(attribute)
    @absorbing_organisation[attribute] ||= @merging_organisations.any? { |merging_organisation| merging_organisation[attribute] }
  end

  def parent_relationship_exists_on_absorbing_organisation?(parent_organisation_relationship)
    parent_organisation_relationship.parent_organisation == @absorbing_organisation || @absorbing_organisation.parent_organisation_relationships.where(parent_organisation: parent_organisation_relationship.parent_organisation).exists?
  end

  def child_relationship_exists_on_absorbing_organisation?(child_organisation_relationship)
    child_organisation_relationship.child_organisation == @absorbing_organisation || @absorbing_organisation.child_organisation_relationships.where(child_organisation: child_organisation_relationship.child_organisation).exists?
  end
end
