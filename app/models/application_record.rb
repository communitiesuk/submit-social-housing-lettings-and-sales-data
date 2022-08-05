class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def strip_whitespaces
    fields_to_strip.each { |field| self[field] = self[field].strip if field.present? }
  end
end
