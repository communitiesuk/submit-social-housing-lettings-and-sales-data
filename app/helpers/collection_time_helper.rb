module CollectionTimeHelper
  def collection_start_year(date)
    window_end_date = Time.zone.local(date.year, 4, 1)
    date < window_end_date ? date.year - 1 : date.year
  end

  def current_collection_start_year
    collection_start_year(Time.zone.now)
  end

  def collection_start_date(date)
    Time.zone.local(collection_start_year(date), 4, 1)
  end

  def date_mid_collection_year_formatted(date)
    example_date = date.nil? ? Time.zone.today : collection_start_date(date).to_date + 5.months
    example_date.to_formatted_s(:govuk_date_number_month)
  end

  def current_collection_start_date
    Time.zone.local(current_collection_start_year, 4, 1)
  end

  def collection_end_date(date)
    Time.zone.local(collection_start_year(date) + 1, 3, 31).end_of_day
  end

  def current_collection_end_date
    Time.zone.local(current_collection_start_year + 1, 3, 31).end_of_day
  end

  def previous_collection_end_date
    current_collection_end_date - 1.year
  end

  def next_collection_start_year
    current_collection_start_year + 1
  end

  def previous_collection_start_year
    current_collection_start_year - 1
  end

  def previous_collection_start_date
    current_collection_start_date - 1.year
  end

  def currently_crossover_period?
    # generally the crossover period ends on the first Friday in June, but there may be arbitrary exceptions such as in 2023
    today = Time.zone.today
    if today.year == 2023
      today.between?(Time.zone.local(2023, 4, 1).to_date, Time.zone.local(2023, 6, 9).to_date)
    else
      crossover_end_date = Time.zone.local(today.year, 6, 1).to_date
      crossover_end_date += 1 until crossover_end_date.friday?
      today.between?(Time.zone.local(today.year, 4, 1).to_date, crossover_end_date)
    end
  end
end
