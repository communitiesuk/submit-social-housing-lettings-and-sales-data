module CollectionTimeHelper
  def current_collection_start_year
    today = Time.zone.now
    window_end_date = Time.zone.local(today.year, 4, 1)
    today < window_end_date ? today.year - 1 : today.year
  end

  def collection_start_date(date)
    window_end_date = Time.zone.local(date.year, 4, 1)
    date < window_end_date ? Time.zone.local(date.year - 1, 4, 1) : Time.zone.local(date.year, 4, 1)
  end

  def date_mid_collection_year_formatted(date)
    example_date = date.nil? ? Time.zone.today : collection_start_date(date).to_date + 5.months
    example_date.to_formatted_s(:govuk_date_number_month)
  end

  def current_collection_start_date
    Time.zone.local(current_collection_start_year, 4, 1)
  end
end
