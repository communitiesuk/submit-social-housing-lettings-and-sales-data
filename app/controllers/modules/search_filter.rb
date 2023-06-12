module Modules::SearchFilter
  def filtered_collection(base_collection, search_term = nil)
    FilterManager.filter_by_search(base_collection, search_term)
  end

  def filtered_users(base_collection, search_term = nil)
    FilterManager.filter_by_search(base_collection, search_term).includes(:organisation)
  end
end
