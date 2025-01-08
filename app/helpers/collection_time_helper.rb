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

  def quarter_deadlines
    Form::QUARTERLY_DEADLINES
  end

  def quarter_deadlines_for_year(year)
    quarter_deadlines[year]
  end

  def first_quarter(year)
    {
      cutoff_date: quarter_deadlines_for_year(year)[:first_quarter_deadline],
      start_date: Time.zone.local(year, 4, 1),
      end_date: Time.zone.local(year, 6, 30),
    }
  end

  def second_quarter(year)
    {
      cutoff_date: quarter_deadlines_for_year(year)[:second_quarter_deadline],
      start_date: Time.zone.local(year, 7, 1),
      end_date: Time.zone.local(year, 9, 30),
    }
  end

  def third_quarter(year)
    {
      cutoff_date: quarter_deadlines_for_year(year)[:third_quarter_deadline],
      start_date: Time.zone.local(year, 10, 1),
      end_date: Time.zone.local(year, 12, 31),
    }
  end

  def fourth_quarter(year)
    {
      cutoff_date: quarter_deadlines_for_year(year)[:fourth_quarter_deadline],
      start_date: Time.zone.local(year + 1, 1, 1),
      end_date: Time.zone.local(year + 1, 3, 31),
    }
  end

  def quarter_dates(year)
    [
      first_quarter(year).merge(quarter: "Q1"),
      second_quarter(year).merge(quarter: "Q2"),
      third_quarter(year).merge(quarter: "Q3"),
    ]
  end

  def quarter_for_date(date: Time.zone.now)
    quarters = quarter_dates(current_collection_start_year)

    quarter = quarters.find { |q| date.between?(q[:start_date], q[:cutoff_date] + 1.day) }

    return unless quarter

    OpenStruct.new(
      quarter: quarter[:quarter],
      cutoff_date: quarter[:cutoff_date],
      quarter_start_date: quarter[:start_date],
      quarter_end_date: quarter[:end_date],
    )
  end
end
