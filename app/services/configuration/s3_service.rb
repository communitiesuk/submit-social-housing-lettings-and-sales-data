module Configuration
  class S3Service
    attr_reader :name

    def initialize(name:)
      @name = name
    end

    def credentials
      return @credentials if @credentials

      raise "bucket: #{name} not found" if vcap_services[:"aws-s3-bucket"].find { |e| e[:instance_name] == name }.blank?

      @credentials = vcap_services[:"aws-s3-bucket"].find { |e| e[:instance_name] == name }[:credentials]
    end

  private

    def vcap_services
      raise "VCAP_SERVICES not found" if ENV["VCAP_SERVICES"].blank?

      @vcap_services ||= JSON.parse(ENV["VCAP_SERVICES"], symbolize_names: true)
    end
  end
end
