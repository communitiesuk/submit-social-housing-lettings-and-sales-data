class FormHandler
  include Singleton
  include CollectionTimeHelper
  attr_reader :forms

  def initialize
    @forms = get_all_forms
  end

  def get_form(form)
    @forms[form]
  end

  def current_lettings_form
    forms["current_lettings"]
  end

  def current_sales_form
    forms["current_sales"]
  end

  def sales_forms
    sales_sections = [
      Form::Sales::Sections::PropertyInformation,
      Form::Sales::Sections::Household,
      Form::Sales::Sections::Finances,
      Form::Sales::Sections::SaleInformation,
    ]
    current_form = Form.new(nil, current_collection_start_year, sales_sections, "sales")
    previous_form = Form.new(nil, current_collection_start_year - 1, sales_sections, "sales")
    next_form = Form.new(nil, current_collection_start_year + 1, sales_sections, "sales")
    { "current_sales" => current_form,
      "previous_sales" => previous_form,
      "next_sales" => next_form }
  end

  def lettings_forms
    forms = {}
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form = Form.new(form_path)

        form_to_set = form_name_from_start_year(form.start_date.year, "lettings")
        forms[form_to_set] = form if forms[form_to_set].blank?
      end
    end

    lettings_sections = [
      Form::Lettings::Sections::TenancyAndProperty,
      Form::Lettings::Sections::Household,
      Form::Lettings::Sections::RentAndCharges,
    ]

    if forms["previous_lettings"].blank? && current_collection_start_year >= 2022
      forms["previous_lettings"] = Form.new(nil, current_collection_start_year - 1, lettings_sections, "lettings")
    end
    forms["current_lettings"] = Form.new(nil, current_collection_start_year, lettings_sections, "lettings") if forms["current_lettings"].blank?
    forms["next_lettings"] = Form.new(nil, current_collection_start_year + 1, lettings_sections, "lettings") if forms["next_lettings"].blank?

    forms
  end

  def lettings_form_for_start_year(year)
    lettings_forms.values.find { |form| form.start_date.year == year }
  end

  def sales_form_for_start_year(year)
    sales_forms.values.find { |form| form.start_date.year == year }
  end

  def form_name_from_start_year(year, type)
    form_mappings = { 0 => "current_#{type}", 1 => "previous_#{type}", -1 => "next_#{type}" }
    form_mappings[current_collection_start_year - year]
  end

  def in_crossover_period?(now: Time.zone.now)
    lettings_in_crossover_period?(now:) || sales_in_crossover_period?(now:)
  end

  def lettings_in_crossover_period?(now: Time.zone.now)
    forms = lettings_forms.values
    forms.count { |form| form.start_date < now && now < form.end_date } > 1
  end

  def sales_in_crossover_period?(now: Time.zone.now)
    forms = sales_forms.values
    forms.count { |form| form.start_date < now && now < form.end_date } > 1
  end

  def use_fake_forms!
    @directories = ["spec/fixtures/forms"]
    @forms = get_all_forms
  end

  def use_real_forms!
    @directories = ["config/forms"]
    @forms = get_all_forms
  end

private

  def get_all_forms
    lettings_forms.merge(sales_forms)
  end

  def directories
    @directories ||= Rails.env.test? ? ["spec/fixtures/forms"] : ["config/forms"]
  end
end
