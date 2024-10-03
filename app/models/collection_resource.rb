class CollectionResource
  include ActiveModel::Model

  attr_accessor :display_name, :short_display_name, :year, :log_type, :download_filename, :download_path
end
