class CaseLog < ApplicationRecord
  enum status: ["in progress", "submitted"]
end
