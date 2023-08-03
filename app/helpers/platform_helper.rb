module PlatformHelper
  def self.is_paas?
    !ENV["VCAP_SERVICES"].nil?
  end
end
