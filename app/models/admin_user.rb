class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :omniauthable
  devise :two_factor_authenticatable, :database_authenticatable, :recoverable,
         :rememberable, :validatable, :trackable, :lockable

  has_one_time_password(encrypted: true)

  has_paper_trail

  validates :phone, presence: true, numericality: true

  MFA_SMS_TEMPLATE_ID = "bf309d93-804e-4f95-b1f4-bd513c48ecb0".freeze
  RESET_PASSWORD_TEMPLATE_ID = "fbb2d415-b9b1-4507-ba0a-6e542fa3504d".freeze

  def send_two_factor_authentication_code(code)
    template_id = MFA_SMS_TEMPLATE_ID
    personalisation = { otp: code }
    Sms.send(phone, template_id, personalisation)
  end

  def reset_password_notify_template
    RESET_PASSWORD_TEMPLATE_ID
  end
end
