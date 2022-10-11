class SalesLogValidator < ActiveModel::Validator

  # included do
  #   validates :beds, numericality: { only_integer: true }, presence: true, comparison: { greater_than: 0, less_than: 10 }
  # end
  def self.included(klass)
    #klass.extend(ClassMethods)
    puts "INCLUDING VALIDATIONS"
    validates :beds, numericality: { only_integer: true }, comparison: { greater_than: 0, less_than: 10 }


  end

  SalesLogValidator.class_eval do
    p "class_eval - self is: " + self.to_s
    def frontend
      p "inside a method self is: " + self.to_s
    end
    validates :beds, numericality: { only_integer: true }, comparison: { greater_than: 0, less_than: 10 }

  end



  # Validations methods need to be called 'validate_' to run on model save
  # or form page submission
  include Validations::Sales::PropertyInformationValidations
  #extend ActiveSupport::Concern


  def validate(record)
    validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
    validation_methods.each { |meth| public_send(meth, record) }
  end
end

class SalesLog < Log
  include DerivedVariables::SalesLogVariables

  self.inheritance_column = :_type_disabled

  has_paper_trail

  #validates :beds, numericality: { only_integer: true }, presence: true, comparison: { greater_than: 0, less_than: 10 }
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

  def bedsit?
    proptype == 2
  end
end
