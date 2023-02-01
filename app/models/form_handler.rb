class FormHandler
  include Singleton
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
    { "current_sales" => current_form,
      "previous_sales" => previous_form }
  end

  def lettings_forms
    lettings_forms = [
      Form::Lettings::Sections::Household,
      Form::Lettings::Sections::RentAndCharges,
      Form::Lettings::Sections::TenancyAndProperty,
    ]
    current_form = Form.new(nil, current_collection_start_year, lettings_forms, "lettings")

    forms = { "current_lettings" => current_form }
    directories.each do |directory|
      Dir.glob("#{directory}/*.json").each do |form_path|
        form = Form.new(form_path)

        form_to_set = form_name_from_start_year(form.start_date.year, "lettings")
        if form && form.start_date.year == 2021 && forms[form_to_set].blank?
          forms[form_to_set] = form
        end
      end
    end
    forms
  end

  def current_collection_start_year
    today = Time.zone.now
    window_end_date = Time.zone.local(today.year, 4, 1)
    today < window_end_date ? today.year - 1 : today.year
  end

  def collection_start_date(date)
    window_end_date = Time.zone.local(date.year, 4, 1)
    date < window_end_date ? Time.zone.local(date.year - 1, 4, 1) : Time.zone.local(date.year, 4, 1)
  end

  def current_collection_start_date
    Time.zone.local(current_collection_start_year, 4, 1)
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
