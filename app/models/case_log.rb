class CaseLog < ApplicationRecord
  enum status: { "in progress" => 0, "submitted" => 1 }
end
