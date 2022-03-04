require "rails_helper"

RSpec.describe PaasConfigurationService do
  subject(:config_service) { described_class.new(logger) }

  let(:logger) { instance_double(ActiveSupport::LogSubscriber) }

  context "when the paas configuration is unavailable" do
    before { allow(logger).to receive(:warn) }

    it "returns the configuration as not present" do
      expect(config_service.config_present?).to be(false)
    end

    it "returns the S3 configuration as not present" do
      expect(config_service.s3_config_present?).to be(false)
    end

    it "does not retrieve any S3 bucket configuration" do
      expect(config_service.s3_buckets).to be_a(Hash)
      expect(config_service.s3_buckets).to be_empty
    end

    it "does not retrieve any redis configuration" do
      expect(config_service.redis_uris).to be_a(Hash)
      expect(config_service.redis_uris).to be_empty
    end
  end

  context "when configuration is present but invalid" do
    let(:vcap_services) { "random text" }

    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
      allow(logger).to receive(:warn)
    end

    it "logs an error" do
      expect(logger).to receive(:warn).with("Could not parse VCAP_SERVICES!")
      config_service.s3_config_present?
    end
  end

  context "when the paas configuration is present with S3 buckets" do
    let(:vcap_services) do
      <<-JSON
        {"aws-s3-bucket": [{"instance_name": "bucket_1"},{"instance_name": "bucket_2"}]}
      JSON
    end

    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
    end

    it "returns the configuration as present" do
      expect(config_service.config_present?).to be(true)
    end

    it "returns the S3 configuration as present" do
      expect(config_service.s3_config_present?).to be(true)
    end

    it "does retrieve the S3 bucket configurations" do
      s3_buckets = config_service.s3_buckets

      expect(s3_buckets).not_to be_empty
      expect(s3_buckets.count).to be(2)
      expect(s3_buckets).to have_key(:bucket_1)
      expect(s3_buckets).to have_key(:bucket_2)
    end
  end

  context "when the paas configuration is present without S3 buckets" do
    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("{}")
    end

    it "returns the configuration as present" do
      expect(config_service.config_present?).to be(true)
    end

    it "returns the S3 configuration as not present" do
      expect(config_service.s3_config_present?).to be(false)
    end

    it "does not retrieve any S3 bucket configuration" do
      expect(config_service.s3_buckets).to be_a(Hash)
      expect(config_service.s3_buckets).to be_empty
    end
  end

  context "when the paas configuration is present with redis configurations" do
    let(:vcap_services) do
      <<-JSON
        {"redis": [{"instance_name": "redis_1", "credentials": {"uri": "redis_uri" }}]}
      JSON
    end

    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
    end

    it "returns the configuration as present" do
      expect(config_service.config_present?).to be(true)
    end

    it "returns the redis configuration as present" do
      expect(config_service.redis_config_present?).to be(true)
    end

    it "does retrieve the redis configurations" do
      redis_uris = config_service.redis_uris

      expect(redis_uris).not_to be_empty
      expect(redis_uris.count).to be(1)
      expect(redis_uris).to have_key(:redis_1)
      expect(redis_uris[:redis_1]).to eq("redis_uri")
    end
  end

  context "when the paas configuration is present without redis configuration" do
    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("{}")
    end

    it "returns the configuration as present" do
      expect(config_service.config_present?).to be(true)
    end

    it "returns the redis configuration as not present" do
      expect(config_service.redis_config_present?).to be(false)
    end

    it "does not retrieve any redis uris from configuration" do
      expect(config_service.redis_uris).to be_a(Hash)
      expect(config_service.redis_uris).to be_empty
    end
  end

end
