module Modules::SearchFilter
  def filtered_collection(base_collection, search_term = nil)
    if search_term.present?
      base_collection.search_by(search_term)
    else
      base_collection
    end
  end

  def filtered_users(base_collection, search_term = nil)
    filtered_collection(base_collection, search_term).includes(:organisation)
  end
end
