class LogsFilterManager
  attr_accessor :applied_filters, :current_user

  def initialize(applied_filters = {}, current_user = nil)
    @applied_filters = applied_filters
    @current_user = current_user
  end

  def applied_filters_count
    applied_filters.values.sum do |category|
      if category.is_a?(String)
        category != "all" ? 1 : 0
      else
        category.count(&:present?)
      end
    end
  end
end
