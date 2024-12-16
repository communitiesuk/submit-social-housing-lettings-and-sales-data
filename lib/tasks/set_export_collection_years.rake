desc "Set export collection years for lettings exports"
task set_export_collection_years: :environment do
  Export.where(collection: %w[2022 2023 2024 2025]).find_each do |export|
    export.year = export.collection.to_i
    export.collection = "lettings"
    export.save!
  end
end
