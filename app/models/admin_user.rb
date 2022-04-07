class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :omniauthable
  devise :two_factor_authenticatable, :database_authenticatable, :recoverable,
         :rememberable, :validatable, :trackable, :lockable

  has_one_time_password(encrypted: true)

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

  validates :phone, presence: true, numericality: true

  MFA_TEMPLATE_ID = "6bdf5ee1-8e01-4be1-b1f9-747061d8a24c".freeze
  RESET_PASSWORD_TEMPLATE_ID = "fbb2d415-b9b1-4507-ba0a-6e542fa3504d".freeze

  def send_two_factor_authentication_code(code)
    template_id = MFA_TEMPLATE_ID
    personalisation = { otp: code }
    DeviseNotifyMailer.new.send_email(email, template_id, personalisation)
  end

  def reset_password_notify_template
    RESET_PASSWORD_TEMPLATE_ID
  end
end
