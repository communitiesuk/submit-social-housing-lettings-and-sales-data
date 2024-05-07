module Forms
  class FilterForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :years, :status, :needstypes, :assigned_to, :user, :owning_organisation_select, :owning_organisation, :managing_organisation_select, :managing_organisation

    validates :years, presence: true
  end
end
