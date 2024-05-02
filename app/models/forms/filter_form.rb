module Forms
  class FilterForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :years, :status, :needstypes, :assigned_to, :owned_by, :managed_by

    validates :years, presence: true
  end
end
