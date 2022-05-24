module Modules::UsersFilter
  def filtered_users(base_collection)
    search_param = params["search"]
    if search_param.present?
      base_collection.search_by(search_param)
    else
      base_collection
    end.filter_by_active.includes(:organisation)
  end
end
