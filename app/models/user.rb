class User < ApplicationRecord
  include Constants::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :trackable

  belongs_to :organisation
  has_many :owned_case_logs, through: :organisation
  has_many :managed_case_logs, through: :organisation

  has_paper_trail

  enum role: ROLES

  def case_logs
    CaseLog.for_organisation(organisation)
  end

  def completed_case_logs
    case_logs.completed
  end

  def not_completed_case_logs
    case_logs.not_completed
  end

  RESET_PASSWORD_TEMPLATE_ID = "2c410c19-80a7-481c-a531-2bcb3264f8e6".freeze
  SET_PASSWORD_TEMPLATE_ID   = "257460a6-6616-4640-a3f9-17c3d73d9e91".freeze

  def reset_password_notify_template
    last_sign_in_at ? RESET_PASSWORD_TEMPLATE_ID : SET_PASSWORD_TEMPLATE_ID
  end
end
