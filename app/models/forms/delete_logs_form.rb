module Forms
  class DeleteLogsForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_reader :logs, :log_type, :selected_ids, :search_term, :delete_confirmation_path, :back_to_logs_path, :delete_path

    validate :at_least_one_log_selected

    def initialize(attributes)
      @log_type = attributes[:log_type]
      @search_term = attributes[:search_term]
      @current_user = attributes[:current_user]
      @logs = FilterManager.filter_logs(visible_logs, @search_term, attributes[:log_filters], nil, @current_user)
      @selected_ids = attributes[:selected_ids] || @logs.map(&:id)
      @delete_confirmation_path = attributes[:delete_confirmation_path]
      @back_to_logs_path = attributes[:back_to_logs_path]
      @delete_path = attributes[:delete_path]
    end

    def log_count
      @logs.count
    end

    def table_partial_name
      "logs/delete_logs_table_#{@log_type}"
    end

  private

    def at_least_one_log_selected
      if selected_ids.blank? || selected_ids.reject(&:blank?).blank?
        errors.add(:log_ids, "Select at least one log to delete or press cancel to return")
      end
    end

    def visible_logs
      case @log_type
      when :lettings then @current_user.lettings_logs.visible
      when :sales then @current_user.sales_logs.visible
      end
    end
  end
end
