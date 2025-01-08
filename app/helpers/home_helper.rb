module HomeHelper
  def quarterly_cutoff_date(quarter, year)
    send("#{quarter}_quarter", year)[:cutoff_date].strftime("%A %-d %B %Y")
  end

  def formatted_deadline
    quarterly_cutoff_date("fourth", current_collection_start_year)
  end
end
