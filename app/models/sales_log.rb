class SalesLogValidator < ActiveModel::Validator
  include Validations::Sales::HouseholdValidations
  include Validations::SharedValidations

  def validate(record)
    validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
    validation_methods.each { |meth| public_send(meth, record) }
  end
end

class SalesLog < Log
  include DerivedVariables::SalesLogVariables

  self.inheritance_column = :_type_disabled

  has_paper_trail

  validates_with SalesLogValidator
  before_validation :set_derived_fields!
  before_validation :reset_invalidated_dependent_fields!

  scope :filter_by_year, ->(year) { where(saledate: Time.zone.local(year.to_i, 4, 1)...Time.zone.local(year.to_i + 1, 4, 1)) }
  scope :search_by, ->(param) { filter_by_id(param) }

  OPTIONAL_FIELDS = %w[purchid].freeze

  def startdate
    saledate
  end

  def self.editable_fields
    attribute_names
  end

  def form_name
    return unless saledate

    FormHandler.instance.form_name_from_start_year(collection_start_year, "sales")
  end

  def form
    FormHandler.instance.get_form(form_name) || FormHandler.instance.current_sales_form
  end

  def optional_fields
    []
  end

  def not_started?
    status == "not_started"
  end

  def completed?
    status == "completed"
  end

  def setup_completed?
    form.setup_sections.all? { |sections| sections.subsections.all? { |subsection| subsection.status(self) == :completed } }
  end

  def unresolved
    false
  end
end
