module CollectionTimeHelper
  def collection_start_year_for_date(date)
    window_end_date = Time.zone.local(date.year, 4, 1)
    date < window_end_date ? date.year - 1 : date.year
  end

  def current_collection_start_year
    collection_start_year_for_date(Time.zone.now)
  end

  def collection_start_date(date)
    Time.zone.local(collection_start_year_for_date(date), 4, 1)
  end

  def date_mid_collection_year_formatted(date)
    relevant_year = date.nil? ? current_collection_start_year : collection_start_year_for_date(date)
    example_date = Date.new(relevant_year, 9, 13)
    example_date.to_formatted_s(:govuk_date_number_month)
  end

  def current_collection_start_date
    Time.zone.local(current_collection_start_year, 4, 1)
  end

  def collection_end_date(date)
    Time.zone.local(collection_start_year_for_date(date) + 1, 3, 31).end_of_day
  end

  def current_collection_end_date
    Time.zone.local(current_collection_start_year + 1, 3, 31).end_of_day
  end

  def current_collection_end_year
    current_collection_start_year + 1
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

  def archived_collection_start_year
    current_collection_start_year - 2
  end

  def generate_different_date_within_collection_year(date, start_date_override: nil, end_date_override: nil)
    start_date = [start_date_override, collection_start_date(date).to_date].compact.max.to_date
    end_date = [end_date_override, collection_end_date(date).to_date].compact.min.to_date

    return nil if start_date > end_date || start_date == end_date

    available_dates = (start_date..end_date).to_a - [date.to_date]
    available_dates.empty? ? nil : available_dates.sample
  end
end
