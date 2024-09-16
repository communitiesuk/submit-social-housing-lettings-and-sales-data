class HomepagePresenter
  include Rails.application.routes.url_helpers
  include CollectionTimeHelper

  attr_reader :current_year_in_progress_lettings_data, :current_year_completed_lettings_data, :current_year_in_progress_sales_data, :current_year_completed_sales_data, :last_year_in_progress_lettings_data, :last_year_completed_lettings_data, :last_year_in_progress_sales_data, :last_year_completed_sales_data, :incomplete_schemes_data, :active_notifications

  def initialize(user)
    @user = user
    @display_sales = should_display_sales?
    @in_crossover_period = FormHandler.instance.in_crossover_period?
    @current_year = current_collection_start_year
    @current_year_in_progress_lettings_data = data_box_data(:lettings, @current_year, :in_progress)
    @current_year_completed_lettings_data = data_box_data(:lettings, @current_year, :completed)
    @current_year_in_progress_sales_data = data_box_data(:sales, @current_year, :in_progress) if display_sales?
    @current_year_completed_sales_data = data_box_data(:sales, @current_year, :completed) if display_sales?
    @last_year = @current_year - 1
    @last_year_in_progress_lettings_data = data_box_data(:lettings, @last_year, :in_progress) if in_crossover_period?
    @last_year_completed_lettings_data = data_box_data(:lettings, @last_year, :completed)
    @last_year_in_progress_sales_data = data_box_data(:sales, @last_year, :in_progress) if in_crossover_period? && display_sales?
    @last_year_completed_sales_data = data_box_data(:sales, @last_year, :completed) if display_sales?
    if display_schemes?
      @incomplete_schemes_data = {
        count: @user.schemes.visible.incomplete.count,
        text: data_box_text(type: :schemes, status: :incomplete),
        path: schemes_path(status: [:incomplete], owning_organisation_select: "all"),
      }
    end
    @active_notifications = Notification.active if @user.support?
  end

  def title_text_for_user
    if @user.support?
      "Manage all data"
    elsif @user.data_coordinator?
      "Manage your organisation's logs"
    else
      "Manage logs assigned to you"
    end
  end

  def display_sales?
    @display_sales
  end

  def in_crossover_period?
    @in_crossover_period
  end

  def subheading_for_current_year
    subheading_from_year @current_year
  end

  def subheading_for_last_year
    subheading = subheading_from_year @last_year
    in_crossover_period? ? subheading : "#{subheading} (Closed collection year)"
  end

  def display_schemes?
    !@user.data_provider?
  end

private

  def subheading_from_year(year)
    "#{year} to #{year + 1} Logs"
  end

  def data_box_data(type, year, status)
    {
      count: logs_count(type:, year:, status:),
      text: data_box_text(type:, status:),
      path: logs_link(type:, year:, status:),
    }
  end

  def data_box_text(type:, status:)
    text = [status, type]
    text.reverse! if status == :in_progress
    text.join(" ").humanize
  end

  def logs_link(type:, year:, status:)
    params = {
      status: [status],
      years: [year],
      assigned_to: @user.data_provider? ? "you" : "all",
      owning_organisation_select: "all",
      managing_organisation_select: "all",
    }
    case type
    when :lettings then lettings_logs_path(params)
    when :sales then sales_logs_path(params)
    end
  end

  def logs_count(type:, year:, status:)
    query = case type
            when :lettings then @user.lettings_logs
            when :sales then @user.sales_logs
            end
    query = query.where(assigned_to: @user) if @user.data_provider?
    query.filter_by_year(year)
         .where(status:)
         .count
  end

  def should_display_sales?
    @user.support? || @user.organisation.sales_logs.exists?
  end
end
