class AddRelationshipsForOrganization < ActiveRecord::Migration[7.0]

  class Organisation < ApplicationRecord
    has_many :users, dependent: :destroy
    has_many :case_logs, dependent: :destroy
    has_many :schemes, dependent: :destroy
  end
  
  class User < ApplicationRecord
    belongs_to :organization
  end
  
  class CaseLog < ApplicationRecord
    belongs_to :organization
  end
  
  class CaseLog < ApplicationRecord
    belongs_to :organization
  end
end
