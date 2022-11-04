class SalesLogValidator < ActiveModel::Validator
  include Validations::Sales::PropertyInformationValidations

  def validate(record)
    validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
    validation_methods.each { |meth| public_send(meth, record) }
  end
end

class SalesLog < Log
  include DerivedVariables::SalesLogVariables

  self.inheritance_column = :_type_disabled

  has_paper_trail

  ## Custom validations
  validates_with SalesLogValidator

  before_validation :set_derived_fields!
  before_validation :reset_invalidated_dependent_fields!
  before_validation :process_postcode_changes!, if: :postcode_full_changed?

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

  # NOTE: Assume if the postcode is not found by the
  # Postcode service, entered value is still valid. E.g.
  # if the Postcode service timesout/unavailable then still
  # need to proceed
  def process_postcode_changes!
    if postcode_full.blank?
      reset_postcode_fields
      return
    end

    self.pcodenk = false
    self.postcode_known = 1

    if postcode_lookup&.result?
      self.pcode1 = postcode_lookup.outcode
      self.pcode2 = postcode_lookup.incode
      self.la = postcode_lookup.location_admin_district
      self.la_known = 1
    else
      self.pcode1 = nil
      self.pcode2 = nil
      self.la = nil
      self.la_known = 0
    end
  end

  def reset_postcode_fields
    self.pcodenk = true
    self.postcode_known = 0
    self.pcode1 = nil
    self.pcode2 = nil
    self.la = nil
    self.la_known = 0
  end

  def postcode_lookup
    @postcode_lookup ||= PostcodeService.new.lookup(postcode_full)
  end

  # 1: Yes
  def postcode_known?
    postcode_known == 1
  end

  # 1: Yes
  def la_known?
    la_known == 1
  end

  def postcode_full=(postcode)
    if postcode.present?
      super UKPostcode.parse(upcase_and_remove_whitespace(postcode)).to_s
      self.postcode_known = 1
    else
      super nil
    end
  end

  def upcase_and_remove_whitespace(string)
    string.present? ? string.upcase.gsub(/\s+/, "") : string
  end
end
