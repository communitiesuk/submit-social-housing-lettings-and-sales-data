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
    return unless saledate

    "#{collection_start_year}_#{collection_start_year + 1}_sales"
  end

  def form
    FormHandler.instance.get_form(form_name) || FormHandler.instance.get_form("2022_2023_sales")
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
