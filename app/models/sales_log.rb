class SalesLogValidator < ActiveModel::Validator
  def validate(record); end
end

class SalesLog < Log
  has_paper_trail

  validates_with SalesLogValidator

  scope :filter_by_year, ->(year) { where(saledate: Time.zone.local(year.to_i, 4, 1)...Time.zone.local(year.to_i + 1, 4, 1)) }
  scope :search_by, ->(param) { filter_by_id(param) }

  OPTIONAL_FIELDS = [].freeze

  def startdate
    saledate
  end

  def self.editable_fields
    attribute_names
  end

  def form_name
    return unless startdate

    form_mappings = { 0 => "current_sales", 1 => "previous_sales", -1 => "next_sales" }
    form_mappings[FormHandler.instance.current_collection_start_year - collection_start_year] if collection_start_year.present?
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
end
