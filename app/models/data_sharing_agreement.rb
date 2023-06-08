class DataSharingAgreement < ApplicationRecord
  belongs_to :organisation
  belongs_to :data_protection_officer, class_name: "User", optional: true
end
