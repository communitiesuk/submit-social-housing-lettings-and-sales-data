module Modules::UsersFilter
  def filtered_users(base_collection, search_term=nil)
    if search_term.present?
      base_collection.search_by(search_term)
    else
      base_collection
    end.filter_by_active.includes(:organisation)
  end
end
