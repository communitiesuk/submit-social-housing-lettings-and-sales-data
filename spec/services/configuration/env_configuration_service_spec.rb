require "rails_helper"

RSpec.describe Configuration::EnvConfigurationService do
  subject(:config_service) { described_class.new(logger) }

  let(:logger) { instance_double(ActiveSupport::LogSubscriber) }

  context "when environment configurations are unavailable" do
    before { allow(logger).to receive(:warn) }

    it "returns the S3 configuration as not present" do
      expect(config_service.s3_config_present?).to be(false)
    end

    it "returns the redis configuration as not present" do
      expect(config_service.redis_config_present?).to be(false)
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

  context "when environment configurations are present but invalid" do
    let(:env_variable) { "random text" }

    before do
      allow(ENV).to receive(:[]).with("S3_CONFIG").and_return(env_variable)
      allow(ENV).to receive(:[]).with("REDIS_CONFIG").and_return(env_variable)
      allow(logger).to receive(:warn)
    end

    it "logs an error when checking if the S3 config is present" do
      expect(logger).to receive(:warn).with("Could not parse S3_CONFIG!")
      config_service.s3_config_present?
    end

    it "logs an error when checking if the Redis config is present" do
      expect(logger).to receive(:warn).with("Could not parse REDIS_CONFIG!")
      config_service.redis_config_present?
    end
  end

  context "when environment configurations are present with S3 configured" do
    let(:s3_config) do
      <<~JSON
        [
          {
            "instance_name": "bucket_1",
            "credentials": {
              "aws_access_key_id": "123",
              "aws_secret_access_key": "456",
              "aws_region": "eu-west-1",
              "bucket_name": "my-bucket"
            }
          },
          {
            "instance_name": "bucket_2",
            "credentials": {
              "aws_access_key_id": "789",
              "aws_secret_access_key": "012",
              "aws_region": "eu-west-2",
              "bucket_name": "my-bucket2"
            }
          }
        ]
      JSON
    end

    before do
      allow(ENV).to receive(:[]).with("REDIS_CONFIG")
      allow(ENV).to receive(:[]).with("S3_CONFIG").and_return(s3_config)
    end

    it "returns the S3 configuration as present" do
      expect(config_service.s3_config_present?).to be(true)
    end

    it "returns the redis configuration as not present" do
      expect(config_service.redis_config_present?).to be(false)
    end

    it "does retrieve the S3 bucket configurations" do
      s3_buckets = config_service.s3_buckets

      expect(s3_buckets).not_to be_empty
      expect(s3_buckets.count).to be(2)
      expect(s3_buckets).to have_key(:bucket_1)
      expect(s3_buckets).to have_key(:bucket_2)
    end
  end

  context "when environment configurations are present with redis configured" do
    let(:redis_config) do
      <<-JSON
        [{"instance_name": "redis_1", "credentials": {"uri": "redis_uri" }}]
      JSON
    end

    before do
      allow(ENV).to receive(:[]).with("S3_CONFIG")
      allow(ENV).to receive(:[]).with("REDIS_CONFIG").and_return(redis_config)
    end

    it "returns the redis configuration as present" do
      expect(config_service.redis_config_present?).to be(true)
    end

    it "returns the S3 configuration as not present" do
      expect(config_service.s3_config_present?).to be(false)
    end

    it "does retrieve the redis configurations" do
      redis_uris = config_service.redis_uris

      expect(redis_uris).not_to be_empty
      expect(redis_uris.count).to be(1)
      expect(redis_uris).to have_key(:redis_1)
      expect(redis_uris[:redis_1]).to eq("redis_uri")
    end
  end
end
