class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :trackable

  belongs_to :organisation
  has_many :owned_case_logs, through: :organisation
  has_many :managed_case_logs, through: :organisation

  def case_logs
    CaseLog.for_organisation(organisation)
  end

  def completed_case_logs
    case_logs.completed
  end

  def not_completed_case_logs
    case_logs.not_completed
  end

  def name_email_display
    %i[name email].map { |field| public_send(field) }.join("\n")
  end

  def org_role_display
    [organisation.name, role].join("\n")
  end

  def last_sign_in_at_display
    return unless last_sign_in_at

    last_sign_in_at.strftime("%d %b %Y")
  end
end
