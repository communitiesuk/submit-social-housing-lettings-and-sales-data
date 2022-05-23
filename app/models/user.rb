class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :trackable, :lockable, :two_factor_authenticatable, :confirmable, :timeoutable

  belongs_to :organisation
  has_many :owned_case_logs, through: :organisation
  has_many :managed_case_logs, through: :organisation

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

  ROLES = {
    data_accessor: 0,
    data_provider: 1,
    data_coordinator: 2,
    support: 99,
  }.freeze

  enum role: ROLES

  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :search_by_email, ->(email) { where("email ILIKE ?", "%#{email}%") }
  scope :filter_by_active, -> { where(active: true) }
  scope :search_by, ->(param) { search_by_name(param).or(search_by_email(param)) }

  def case_logs
    if support?
      CaseLog.all
    else
      CaseLog.filter_by_organisation(organisation)
    end
  end

  def completed_case_logs
    case_logs.completed
  end

  def not_completed_case_logs
    case_logs.not_completed
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

  def reset_password_notify_template
    RESET_PASSWORD_TEMPLATE_ID
  end

  def confirmable_template
    if was_migrated_from_softwire?
      BETA_ONBOARDING_TEMPLATE_ID
    else
      CONFIRMABLE_TEMPLATE_ID
    end
  end

  def was_migrated_from_softwire?
    old_user_id.present?
  end

  def skip_confirmation!
    !active?
  end

  def need_two_factor_authentication?(_request)
    return false if Rails.env.development?

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

  def case_logs_filters(specific_org: false)
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
end
