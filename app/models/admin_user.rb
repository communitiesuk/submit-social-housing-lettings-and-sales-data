class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :two_factor_authenticatable, :database_authenticatable, :recoverable,
         :rememberable, :validatable

  has_one_time_password(encrypted: true)

  validates :phone, presence: true, numericality: true

  MFA_SMS_TEMPLATE_ID = "bf309d93-804e-4f95-b1f4-bd513c48ecb0".freeze

  def send_two_factor_authentication_code(code)
    template_id = MFA_SMS_TEMPLATE_ID
    personalisation = { otp: code }
    Sms.send(phone, template_id, personalisation)
  end
end
