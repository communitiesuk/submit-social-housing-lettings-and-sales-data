class Merge::MergeOrganisationsService
  def initialize(absorbing_organisation_id:, merging_organisation_ids:, merge_date: Time.zone.today, absorbing_organisation_active_from_merge_date: false)
    @absorbing_organisation = Organisation.find(absorbing_organisation_id)
    @merging_organisations = Organisation.find(merging_organisation_ids)
    @merge_date = merge_date || Time.zone.today
    @absorbing_organisation_active_from_merge_date = absorbing_organisation_active_from_merge_date
    @pre_to_post_merge_scheme_ids = {}
    @pre_to_post_merge_location_ids = {}
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
      send_success_emails
      log_success_message
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Organisation merge failed with: #{e.message}")
      raise
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
    users_to_merge = users_to_merge(merging_organisation)
    @merged_users[merging_organisation.name] = users_to_merge.map { |user| { name: user.name, email: user.email } }
    users_to_merge.update_all(organisation_id: @absorbing_organisation.id, values_updated_at: Time.zone.now)
  end

  def merge_schemes_and_locations(merging_organisation)
    @merged_schemes[merging_organisation.name] = []
    merging_organisation.owned_schemes.each do |scheme|
      new_scheme = Scheme.new(scheme.attributes.except("id", "owning_organisation_id", "old_id", "old_visible_id").merge(owning_organisation: @absorbing_organisation, startdate: [scheme&.startdate, @merge_date].compact.max))
      new_scheme.save!(validate: false)
      @pre_to_post_merge_scheme_ids[scheme.id] = new_scheme.id
      scheme.scheme_deactivation_periods.each do |deactivation_period|
        split_scheme_deactivation_period_between_organisations(deactivation_period, new_scheme)
      end
      scheme.locations.each do |location|
        new_location = Location.new(location.attributes.except("id", "scheme_id", "old_id", "old_visible_id").merge(scheme: new_scheme, startdate: [location&.startdate, @merge_date].compact.max))
        new_location.save!(validate: false)
        @pre_to_post_merge_location_ids[location.id] = new_location.id
        location.location_deactivation_periods.each do |deactivation_period|
          split_location_deactivation_period_between_organisations(deactivation_period, new_location)
        end
        unless location.status_at(@merge_date) == :deactivated
          deactivation_period = LocationDeactivationPeriod.new(location:, deactivation_date: [location&.startdate, scheme&.startdate, @merge_date].compact.max)
          deactivation_period.save!(validate: false)
        end
      end
      @merged_schemes[merging_organisation.name] << { name: new_scheme.service_name, code: new_scheme.id }
      unless scheme.status_at(@merge_date) == :deactivated
        deactivation_period = SchemeDeactivationPeriod.new(scheme:, deactivation_date: [scheme&.startdate, @merge_date].compact.max)
        deactivation_period.save!(validate: false)
      end
    end
  end

  def merge_lettings_logs(merging_organisation)
    merging_organisation.owned_lettings_logs.after_date(@merge_date.to_time).each do |lettings_log|
      if lettings_log.managing_organisation == merging_organisation
        lettings_log.managing_organisation = @absorbing_organisation
      end
      if lettings_log.scheme.present?
        scheme_to_set = @absorbing_organisation.owned_schemes.find_by(id: @pre_to_post_merge_scheme_ids[lettings_log.scheme.id])
        location_to_set = scheme_to_set.locations.find_by(id: @pre_to_post_merge_location_ids[lettings_log.location&.id])

        lettings_log.scheme = scheme_to_set if scheme_to_set.present?
        # in some cases the lettings_log location is nil even if scheme is present (they're two different questions).
        # in certain cases the location_to_set query can find a location in the scheme with nil values for name and postcode,
        # so we can end up setting the location to non nil.
        # hence the extra check here
        lettings_log.location = location_to_set if location_to_set.present? && lettings_log.location.present?
      end
      lettings_log.owning_organisation = @absorbing_organisation
      lettings_log.managing_organisation = @absorbing_organisation if lettings_log.managing_organisation == merging_organisation
      if lettings_log.collection_period_open?
        lettings_log.skip_dpo_validation = true
        lettings_log.save!
      else
        lettings_log.save!(validate: false)
      end
    end
    merging_organisation.managed_lettings_logs.after_date(@merge_date.to_time).each do |lettings_log|
      lettings_log.managing_organisation = @absorbing_organisation
      if lettings_log.collection_period_open?
        lettings_log.skip_dpo_validation = true
        lettings_log.save!
      else
        lettings_log.save!(validate: false)
      end
    end
  end

  def merge_sales_logs(merging_organisation)
    merging_organisation.owned_sales_logs.after_date(@merge_date.to_time).each do |sales_log|
      if sales_log.managing_organisation == merging_organisation
        sales_log.managing_organisation = @absorbing_organisation
      end
      sales_log.owning_organisation = @absorbing_organisation
      if sales_log.collection_period_open?
        sales_log.skip_dpo_validation = true
        sales_log.save!
      else
        sales_log.save!(validate: false)
      end
    end
    merging_organisation.managed_sales_logs.after_date(@merge_date.to_time).each do |sales_log|
      sales_log.managing_organisation = @absorbing_organisation
      if sales_log.collection_period_open?
        sales_log.skip_dpo_validation = true
        sales_log.save!
      else
        sales_log.save!(validate: false)
      end
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

  def send_success_emails
    @absorbing_organisation.users.each do |user|
      next unless user.active?

      merged_organisation, merged_user = find_merged_user_and_organisation_by_email(user.email)
      if merged_user.present?
        MergeCompletionMailer.send_merged_organisation_success_mail(merged_user[:email], merged_organisation, @absorbing_organisation.name, @merge_date).deliver_later
      else
        MergeCompletionMailer.send_absorbing_organisation_success_mail(user.email, @merging_organisations.map(&:name), @absorbing_organisation.name, @merge_date).deliver_later
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

  def users_to_merge(merging_organisation)
    return merging_organisation.users if merging_organisation.data_protection_confirmation.blank?
    if merging_organisation.data_protection_confirmation.data_protection_officer.email.exclude?("@")
      return merging_organisation.users.where.not(id: merging_organisation.data_protection_confirmation.data_protection_officer.id)
    end

    new_dpo = User.new(
      name: merging_organisation.data_protection_confirmation.data_protection_officer.name,
      organisation: merging_organisation,
      is_dpo: true,
      encrypted_password: SecureRandom.hex(10),
      email: SecureRandom.uuid,
      confirmed_at: Time.zone.now,
      active: false,
    )
    new_dpo.save!(validate: false)
    merging_organisation.data_protection_confirmation.update!(data_protection_officer: new_dpo)

    merging_organisation.users.where.not(id: new_dpo.id)
  end

  def deactivation_happenned_before_merge?(deactivation_period)
    deactivation_period.deactivation_date <= @merge_date && deactivation_period.reactivation_date.present? && deactivation_period.reactivation_date <= @merge_date
  end

  def deactivation_happenned_during_merge?(deactivation_period)
    deactivation_period.deactivation_date <= @merge_date && (deactivation_period.reactivation_date.blank? || deactivation_period.reactivation_date.present? && deactivation_period.reactivation_date >= @merge_date)
  end

  def split_scheme_deactivation_period_between_organisations(deactivation_period, new_scheme)
    return if deactivation_happenned_before_merge?(deactivation_period)

    if deactivation_happenned_during_merge?(deactivation_period)
      new_deactivation_period = SchemeDeactivationPeriod.new(deactivation_period.attributes.except("id", "scheme_id", "deactivation_date").merge(scheme: new_scheme, deactivation_date: @merge_date))
      new_deactivation_period.save!(validate: false)
      if deactivation_period.reactivation_date.present?
        deactivation_period.reactivation_date = nil
        deactivation_period.save!(validate: false)
      end
    else
      new_deactivation_period = SchemeDeactivationPeriod.new(deactivation_period.attributes.except("id", "scheme_id").merge(scheme: new_scheme))
      new_deactivation_period.save!(validate: false)
      deactivation_period.destroy!
    end
  end

  def split_location_deactivation_period_between_organisations(deactivation_period, new_location)
    return if deactivation_happenned_before_merge?(deactivation_period)

    if deactivation_happenned_during_merge?(deactivation_period)
      new_deactivation_period = LocationDeactivationPeriod.new(deactivation_period.attributes.except("id", "location_id", "deactivation_date").merge(location: new_location, deactivation_date: @merge_date))
      new_deactivation_period.save!(validate: false)
      if deactivation_period.reactivation_date.present?
        deactivation_period.reactivation_date = nil
        deactivation_period.save!(validate: false)
      end
    else
      new_deactivation_period = LocationDeactivationPeriod.new(deactivation_period.attributes.except("id", "location_id").merge(location: new_location))
      new_deactivation_period.save!(validate: false)
      deactivation_period.destroy!
    end
  end

  def find_merged_user_and_organisation_by_email(provided_email)
    @merged_users.each do |org, users|
      user = users.find { |u| u[:email] == provided_email }
      return org, user if user
    end
    nil
  end
end
