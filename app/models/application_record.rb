class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def strip_whitespaces
    self.service_name = service_name.strip unless !respond_to?("service_name") || service_name.nil?
    self.name = name.strip unless !respond_to?("name") || name.nil?
  end
end
