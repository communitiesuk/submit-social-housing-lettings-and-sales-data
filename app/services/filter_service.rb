class FilterService
  def self.filter_by_search(base_collection, search_term = nil)
    if search_term.present?
      base_collection.search_by(search_term)
    else
      base_collection
    end
  end

  def self.filter_lettings_logs(logs, search_term, filters, all_orgs, user)
    logs = filter_by_search(logs, search_term)

    filters.each do |category, values|
      next if Array(values).reject(&:empty?).blank?
      next if category == "organisation" && all_orgs

      logs = logs.public_send("filter_by_#{category}", values, user)
    end
    logs = logs.order(created_at: :desc)
    user.support? ? logs.all.includes(:owning_organisation, :managing_organisation) : logs
  end
end
