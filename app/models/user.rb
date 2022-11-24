class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :lockable, :two_factor_authenticatable, :confirmable, :timeoutable

  # Marked as optional because we validate organisation_id below instead so that
  # the error message is linked to the right field on the form
  belongs_to :organisation, optional: true
  has_many :owned_lettings_logs, through: :organisation
  has_many :managed_lettings_logs, through: :organisation
  has_many :owned_sales_logs, through: :organisation
  has_many :managed_sales_logs, through: :organisation
  has_many :legacy_users

  validates :name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: { allow_blank: true, case_sensitive: true, if: :will_save_change_to_email? }
  validates :email, format: { with: Devise.email_regexp, allow_blank: true, if: :will_save_change_to_email? }
  validates :password, presence: { if: :password_required? }
  validates :password, confirmation: { if: :password_required? }
  validates :password, length: { within: Devise.password_length, allow_blank: true }
  validates :organisation_id, presence: true

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

  auto_strip_attributes :name

  ROLES = {
    data_provider: 1,
    data_coordinator: 2,
    support: 99,
  }.freeze

  enum role: ROLES

  scope :search_by_name, ->(name) { where("users.name ILIKE ?", "%#{name}%") }
  scope :search_by_email, ->(email) { where("email ILIKE ?", "%#{email}%") }
  scope :filter_by_active, -> { where(active: true) }
  scope :search_by, ->(param) { search_by_name(param).or(search_by_email(param)) }
  scope :sorted_by_organisation_and_role, -> { joins(:organisation).order("organisations.name", role: :desc, name: :asc) }

  def lettings_logs
    if support?
      LettingsLog.all
    else
      LettingsLog.filter_by_organisation(organisation)
    end
  end

  def sales_logs
    if support?
      SalesLog.all
    else
      SalesLog.filter_by_organisation(organisation)
    end
  end

  def completed_lettings_logs
    lettings_logs.completed
  end

  def not_completed_lettings_logs
    lettings_logs.not_completed
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

  MFA_TEMPLATE_ID = "6bdf5ee1-8e01-4be1-b1f9-747061d8a24c".freeze
  RESET_PASSWORD_TEMPLATE_ID = "2c410c19-80a7-481c-a531-2bcb3264f8e6".freeze
  CONFIRMABLE_TEMPLATE_ID = "257460a6-6616-4640-a3f9-17c3d73d9e91".freeze
  BETA_ONBOARDING_TEMPLATE_ID = "b48bc2cd-5887-4611-8296-d0ab3ed0e7fd".freeze
  USER_REACTIVATED_TEMPLATE_ID = "ac45a899-490e-4f59-ae8d-1256fc0001f9".freeze

  def reset_password_notify_template
    RESET_PASSWORD_TEMPLATE_ID
  end

  def confirmable_template
    if last_sign_in_at.present? && (unconfirmed_email.blank? || unconfirmed_email == email)
      USER_REACTIVATED_TEMPLATE_ID
    elsif was_migrated_from_softwire? && last_sign_in_at.blank?
      BETA_ONBOARDING_TEMPLATE_ID
    else
      CONFIRMABLE_TEMPLATE_ID
    end
  end

  def was_migrated_from_softwire?
    legacy_users.any? || old_user_id.present?
  end

  def send_confirmation_instructions
    return unless active?

    super
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
    return {} unless data_coordinator? || support?
    return ROLES if support?

    ROLES.except(:support)
  end

  def logs_filters(specific_org: false)
    if support? && !specific_org
      %w[status years user organisation]
    else
      %w[status years user]
    end
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
    super && active?
  end

protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
