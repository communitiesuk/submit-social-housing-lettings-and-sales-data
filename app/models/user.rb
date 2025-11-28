class User < ApplicationRecord
  acts_as_reader

  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :lockable, :two_factor_authenticatable, :confirmable, :timeoutable

  # Marked as optional because we validate organisation_id below instead so that
  # the error message is linked to the right field on the form
  belongs_to :organisation, optional: true
  has_many :legacy_users
  has_many :bulk_uploads

  validates :name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: { allow_blank: true, case_sensitive: true, if: :will_save_change_to_email? }
  validates :email, format: { with: Devise.email_regexp, allow_blank: true, if: :will_save_change_to_email? }
  validates :password, presence: { if: :password_required? }
  validates :password, length: { within: Devise.password_length, allow_blank: true }
  validates :password, confirmation: { if: :password_required? }
  validates :phone_extension, format: { with: /\A\d+\z/, allow_blank: true, message: I18n.t("validations.not_number", field: "") }

  after_validation :send_data_protection_confirmation_reminder, if: :is_dpo_changed?

  validates :organisation_id, presence: true
  validate :organisation_not_merged

  has_paper_trail ignore: %w[last_sign_in_at
                             current_sign_in_at
                             current_sign_in_ip
                             last_sign_in_ip
                             failed_attempts
                             unlock_token
                             locked_at
                             reset_password_token
                             reset_password_sent_at
                             remember_created_at
                             sign_in_count
                             updated_at]

  has_one_time_password(encrypted: true)

  auto_strip_attributes :name, squish: true

  ROLES = {
    data_provider: 1,
    data_coordinator: 2,
    support: 99,
  }.freeze

  LOG_REASSIGNMENT = {
    reassign_all: "Yes, change the stock owner and the managing agent",
    reassign_stock_owner: "Yes, change the stock owner but keep the managing agent the same",
    reassign_managing_agent: "Yes, change the managing agent but keep the stock owner the same",
    unassign: "No, unassign the logs",
  }.freeze

  enum :role, ROLES

  scope :search_by_name, ->(name) { where("users.name ILIKE ?", "%#{name}%") }
  scope :search_by_email, ->(email) { where("email ILIKE ?", "%#{email}%") }
  scope :filter_by_active, -> { where(active: true) }
  scope :search_by, ->(param) { search_by_name(param).or(search_by_email(param)) }
  scope :sorted_by_organisation_and_role, -> { joins(:organisation).order("organisations.name", role: :desc, name: :asc) }
  scope :filter_by_status, lambda { |statuses, _user = nil|
    filtered_records = all
    scopes = []

    statuses.each do |status|
      status = status == "active" ? "active_status" : status
      status = status == "unconfirmed" ? "not_signed_in" : status
      if respond_to?(status, true)
        scopes << send(status)
      end
    end

    if scopes.any?
      filtered_records = filtered_records.merge(scopes.reduce(&:or))
    end

    filtered_records
  }
  scope :filter_by_role, ->(role, _user = nil) { where(role:) }
  scope :filter_by_additional_responsibilities, lambda { |additional_responsibilities, _user|
    filtered_records = all
    scopes = []

    additional_responsibilities.each do |responsibility|
      case responsibility
      when "key_contact"
        scopes << send("is_key_contact")
      when "data_protection_officer"
        scopes << send("is_data_protection_officer")
      end
    end

    if scopes.any?
      filtered_records = filtered_records.merge(scopes.reduce(&:or))
    end

    filtered_records
  }

  scope :is_key_contact, -> { where(is_key_contact: true) }
  scope :is_data_protection_officer, -> { where(is_dpo: true) }
  scope :not_signed_in, -> { where(last_sign_in_at: nil, active: true) }
  scope :deactivated, -> { where(active: false) }
  scope :activated, -> { where(active: true) }
  # in some cases we only count the user as active if they completed the onboarding flow and signed in, rather than just being added
  scope :active_status, -> { where(active: true).where.not(last_sign_in_at: nil) }
  scope :visible, lambda { |user = nil|
    if user && !user.support?
      where(discarded_at: nil, organisation: user.organisation.child_organisations + [user.organisation])
    else
      where(discarded_at: nil)
    end
  }

  attr_accessor :log_reassignment

  def lettings_logs
    if support?
      LettingsLog.all
    else
      LettingsLog.filter_by_organisation(organisation.absorbed_organisations + [organisation])
    end
  end

  def sales_logs
    if support?
      SalesLog.all
    else
      SalesLog.filter_by_organisation(organisation.absorbed_organisations + [organisation])
    end
  end

  def owned_lettings_logs
    LettingsLog.filter_by_owning_organisation(organisation.absorbed_organisations + [organisation])
  end

  def managed_lettings_logs
    LettingsLog.filter_by_managing_organisation(organisation.absorbed_organisations + [organisation])
  end

  def owned_sales_logs
    SalesLog.filter_by_owning_organisation(organisation.absorbed_organisations + [organisation])
  end

  def managed_sales_logs
    SalesLog.filter_by_managing_organisation(organisation.absorbed_organisations + [organisation])
  end

  def schemes
    if support?
      Scheme.all
    else
      Scheme.filter_by_owning_organisation(organisation.absorbed_organisations + [organisation] + organisation.parent_organisations)
    end
  end

  def is_key_contact?
    is_key_contact
  end

  def is_key_contact!
    update(is_key_contact: true)
  end

  def is_data_protection_officer?
    is_dpo
  end

  def is_data_protection_officer!
    update!(is_dpo: true)
  end

  def deactivate!(reactivate_with_organisation: false)
    update!(
      active: false,
      confirmed_at: nil,
      sign_in_count: 0,
      initial_confirmation_sent: false,
      reactivate_with_organisation:,
      unconfirmed_email: nil,
    )
  end

  def reactivate!
    update!(
      active: true,
      reactivate_with_organisation: false,
    )
  end

  MFA_TEMPLATE_ID = "6bdf5ee1-8e01-4be1-b1f9-747061d8a24c".freeze
  RESET_PASSWORD_TEMPLATE_ID = "2c410c19-80a7-481c-a531-2bcb3264f8e6".freeze
  CONFIRMABLE_TEMPLATE_ID = "3fc2e3a7-0835-4b84-ab7a-ce51629eb614".freeze
  RECONFIRMABLE_TEMPLATE_ID = "bcdec787-f0a7-46e9-8d63-b3e0a06ee455".freeze
  USER_REACTIVATED_TEMPLATE_ID = "ac45a899-490e-4f59-ae8d-1256fc0001f9".freeze
  FOR_OLD_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID = "3eb80517-1051-4dfc-b4cc-cb18228a3829".freeze
  FOR_NEW_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID = "0cdd0be1-7fa5-4808-8225-ae4c5a002352".freeze
  ORGANISATION_UPDATE_TEMPLATE_ID = "4b7716c0-cc5c-41dd-92e4-a0dff03bdf5e".freeze

  def reset_password_notify_template
    RESET_PASSWORD_TEMPLATE_ID
  end

  def confirmable_template
    if last_sign_in_at.present? && (unconfirmed_email.blank? || unconfirmed_email == email)
      USER_REACTIVATED_TEMPLATE_ID
    elsif initial_confirmation_sent && !confirmed?
      RECONFIRMABLE_TEMPLATE_ID
    else
      CONFIRMABLE_TEMPLATE_ID
    end
  end

  def send_confirmation_instructions
    return unless active?

    super
    update!(initial_confirmation_sent: true)
  end

  def need_two_factor_authentication?(_request)
    return false if Rails.env.development?
    return false if Rails.env.review?

    support?
  end

  def send_two_factor_authentication_code(code)
    template_id = MFA_TEMPLATE_ID
    personalisation = { otp: code }
    DeviseNotifyMailer.new.send_email(email, template_id, personalisation)
  end

  def assignable_roles
    if Rails.env.staging? && in_staging_role_update_email_allowlist?
      return ROLES
    end

    return {} unless data_coordinator? || support?
    return ROLES if support?

    ROLES.except(:support)
  end

  def in_staging_role_update_email_allowlist?
    Rails.application.credentials[:staging_role_update_email_allowlist].include?(email.split("@").last.downcase)
  end

  def logs_filters(specific_org: false)
    if (support? && !specific_org) || organisation.has_managing_agents? || organisation.has_stock_owners?
      %w[years status needstypes salestypes assigned_to user owning_organisation managing_organisation bulk_upload_id user_text_search owning_organisation_text_search managing_organisation_text_search]
    else
      %w[years status needstypes salestypes assigned_to user bulk_upload_id user_text_search]
    end
  end

  def scheme_filters(specific_org: false)
    if (support? && !specific_org) || organisation.has_managing_agents? || organisation.has_stock_owners?
      %w[status owning_organisation owning_organisation_text_search]
    else
      %w[status]
    end
  end

  def bulk_uploads_filters(specific_org: false)
    return [] unless support? && !specific_org

    %w[user years uploaded_by uploading_organisation user_text_search uploading_organisation_text_search]
  end

  delegate :name, to: :organisation, prefix: true

  def self.download_attributes
    %w[id email name organisation_name role old_user_id is_dpo is_key_contact active sign_in_count last_sign_in_at]
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << download_attributes

      all.find_each do |record|
        csv << download_attributes.map { |attr| record.public_send(attr) }
      end
    end
  end

  def can_toggle_active?(user)
    self != user && (support? || data_coordinator?)
  end

  def valid_for_authentication?
    super && account_is_active?
  end

  def account_is_active?
    unless active?
      throw(:warden, message: :inactive_account)
    end
    true
  end

  def editable_duplicate_lettings_logs_sets
    lettings_logs.after_date(FormHandler.instance.lettings_earliest_open_for_editing_collection_start_date).duplicate_sets(id).map { |array_str| array_str ? array_str.map(&:to_i) : [] }
  end

  def editable_duplicate_sales_logs_sets
    sales_logs.after_date(FormHandler.instance.sales_earliest_open_for_editing_collection_start_date).duplicate_sets(id).map { |array_str| array_str ? array_str.map(&:to_i) : [] }
  end

  def active_unread_notifications
    Notification.active.unread_by(self)
  end

  def newest_active_unread_notification
    active_unread_notifications.last
  end

  def status
    return :deleted if discarded_at.present?
    return :deactivated unless active
    return :unconfirmed unless confirmed?

    :active
  end

  def discard!
    self.discarded_at = Time.zone.now
    save!(validate: false)
  end

  def phone_with_extension
    return phone if phone_extension.blank?

    "#{phone}, Ext. #{phone_extension}"
  end

  def assigned_to_lettings_logs
    lettings_logs.where(assigned_to: self)
  end

  def assigned_to_sales_logs
    sales_logs.where(assigned_to: self)
  end

  def reassign_logs_and_update_organisation(new_organisation, log_reassignment)
    return unless new_organisation

    ActiveRecord::Base.transaction do
      lettings_logs_to_reassign = assigned_to_lettings_logs.visible
      sales_logs_to_reassign = assigned_to_sales_logs.visible
      current_organisation = organisation

      logs_count = lettings_logs_to_reassign.count + sales_logs_to_reassign.count
      return if logs_count.positive? && (log_reassignment.blank? || !LOG_REASSIGNMENT.key?(log_reassignment.to_sym))

      update!(organisation: new_organisation)

      case log_reassignment
      when "reassign_all"
        reassign_all_orgs(new_organisation, lettings_logs_to_reassign, sales_logs_to_reassign)
      when "reassign_stock_owner"
        reassign_stock_owners(new_organisation, lettings_logs_to_reassign, sales_logs_to_reassign)
      when "reassign_managing_agent"
        reassign_managing_agents(new_organisation, lettings_logs_to_reassign, sales_logs_to_reassign)
      when "unassign"
        unassign_organisations(lettings_logs_to_reassign, sales_logs_to_reassign, current_organisation)
      end

      cancel_related_bulk_uploads
      send_organisation_change_email(current_organisation, new_organisation, log_reassignment, logs_count)
    rescue StandardError => e
      Rails.logger.error("User update failed with: #{e.message}")
      Sentry.capture_exception(e)

      raise ActiveRecord::Rollback
    end
  end

  def send_reset_password_instructions
    if confirmed?
      super
    else
      send_confirmation_instructions
    end
  end

protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

private

  def organisation_not_merged
    if organisation&.merge_date.present? && organisation.merge_date < Time.zone.now
      errors.add :organisation_id, I18n.t("validations.organisation.merged")
    end
  end

  def send_data_protection_confirmation_reminder
    return unless persisted?
    return unless is_dpo?
    return if organisation.data_protection_confirmed?

    DataProtectionConfirmationMailer.send_confirmation_email(self).deliver_later
  end

  def reassign_all_orgs(new_organisation, lettings_logs_to_reassign, sales_logs_to_reassign)
    lettings_logs_to_reassign.update_all(owning_organisation_id: new_organisation.id, managing_organisation_id: new_organisation.id, values_updated_at: Time.zone.now)
    sales_logs_to_reassign.update_all(owning_organisation_id: new_organisation.id, managing_organisation_id: new_organisation.id, values_updated_at: Time.zone.now)
  end

  def reassign_stock_owners(new_organisation, lettings_logs_to_reassign, sales_logs_to_reassign)
    lettings_logs_to_reassign.update_all(owning_organisation_id: new_organisation.id, values_updated_at: Time.zone.now)
    sales_logs_to_reassign.update_all(owning_organisation_id: new_organisation.id, values_updated_at: Time.zone.now)
  end

  def reassign_managing_agents(new_organisation, lettings_logs_to_reassign, sales_logs_to_reassign)
    lettings_logs_to_reassign.update_all(managing_organisation_id: new_organisation.id, values_updated_at: Time.zone.now)
    sales_logs_to_reassign.update_all(managing_organisation_id: new_organisation.id, values_updated_at: Time.zone.now)
  end

  def unassign_organisations(lettings_logs_to_reassign, sales_logs_to_reassign, current_organisation)
    if User.find_by(name: "Unassigned", organisation: current_organisation)
      unassigned_user = User.find_by(name: "Unassigned", organisation: current_organisation)
    else
      unassigned_user = User.new(
        name: "Unassigned",
        organisation_id:,
        is_dpo: false,
        encrypted_password: SecureRandom.hex(10),
        email: SecureRandom.uuid,
        confirmed_at: Time.zone.now,
        active: false,
      )
      unassigned_user.save!(validate: false)
    end
    lettings_logs_to_reassign.update_all(assigned_to_id: unassigned_user.id, values_updated_at: Time.zone.now)
    sales_logs_to_reassign.update_all(assigned_to_id: unassigned_user.id, values_updated_at: Time.zone.now)
  end

  def send_organisation_change_email(current_organisation, new_organisation, log_reassignment, logs_count)
    reassigned_logs_text = ""
    assigned_logs_count = logs_count == 1 ? "is 1 log" : "are #{logs_count} logs"

    case log_reassignment
    when "reassign_all"
      reassigned_logs_text = "There #{assigned_logs_count} assigned to you. The stock owner and managing agent on #{logs_count == 1 ? 'this log' : 'these logs'} has been changed from #{current_organisation.name} to #{new_organisation.name}."
    when "reassign_stock_owner"
      reassigned_logs_text = "There #{assigned_logs_count} assigned to you. The stock owner on #{logs_count == 1 ? 'this log' : 'these logs'} has been changed from #{current_organisation.name} to #{new_organisation.name}."
    when "reassign_managing_agent"
      reassigned_logs_text = "There #{assigned_logs_count} assigned to you. The managing agent on #{logs_count == 1 ? 'this log' : 'these logs'} has been changed from #{current_organisation.name} to #{new_organisation.name}."
    when "unassign"
      reassigned_logs_text = "There #{assigned_logs_count} assigned to you. #{logs_count == 1 ? 'This' : 'These'} have now been unassigned."
    end

    template_id = ORGANISATION_UPDATE_TEMPLATE_ID
    personalisation = {
      from_organisation: "#{current_organisation.name} (Organisation ID: #{current_organisation.id})",
      to_organisation: "#{new_organisation.name} (Organisation ID: #{new_organisation.id})",
      reassigned_logs_text:,
    }
    DeviseNotifyMailer.new.send_email(email, template_id, personalisation)
  end

  def cancel_related_bulk_uploads
    lettings_bu_ids = LettingsLog.where(assigned_to: self, status: "pending").map(&:bulk_upload_id).compact.uniq
    BulkUpload.where(id: lettings_bu_ids).update!(choice: "cancelled-by-moved-user", moved_user_id: id)

    sales_bu_ids = SalesLog.where(assigned_to: self, status: "pending").map(&:bulk_upload_id).compact.uniq
    BulkUpload.where(id: sales_bu_ids).update!(choice: "cancelled-by-moved-user", moved_user_id: id)
  end
end
