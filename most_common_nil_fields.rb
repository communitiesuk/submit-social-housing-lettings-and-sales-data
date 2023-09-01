blank_attribute_frequencies = Hash.new(0)

items = LettingsLog.where(status: "in_progress").where("owning_organisation_id >= ?", 4466)
i = 0
items.each do |item|
  LettingsLog.attribute_names.each do |attribute_name|
    blank_attribute_frequencies[attribute_name] += 1 if item.send(attribute_name).blank?
  end
  pp i
  i += 1
end

most_common_blank_attributes = blank_attribute_frequencies.sort_by { |_, count| -count }

most_common_blank_attributes.each do |attribute_name, count|
  puts "#{attribute_name}: #{count}"
end
