require "rails_helper"

RSpec.describe Configuration::S3Service do
  subject(:service) { described_class.new(name:) }

  let(:name) { "dluhc-core-review-export-bucket" }

  let(:vcap_services) do
    {
      "aws-s3-bucket" => [
        {
          "label" => "aws-s3-bucket",
          "provider" => nil,
          "plan" => "default",
          "name" => "dluhc-core-review-export-bucket",
          "tags" => %w[s3],
          "instance_guid" => "some-guid",
          "instance_name" => "dluhc-core-review-export-bucket",
          "binding_guid" => "some-guid",
          "binding_name" => nil,
          "credentials" => {
            "bucket_name" => "actual-export-bucket-name",
            "aws_access_key_id" => "access_key_123",
            "aws_secret_access_key" => "secret_access_key_123",
            "aws_region" => "region-1",
            "deploy_env" => "",
          },
          "syslog_drain_url" => nil,
          "volume_mounts" => [],
        },
        {
          "label" => "aws-s3-bucket",
          "provider" => nil,
          "plan" => "default",
          "name" => "dluhc-core-review-csv-bucket",
          "tags" => %w[s3],
          "instance_guid" => "some-guid",
          "instance_name" => "dluhc-core-review-csv-bucket",
          "binding_guid" => "some-guid",
          "binding_name" => nil,
          "credentials" => {
            "bucket_name" => "paas-s3-broker-prod-lon-some-guid",
            "aws_access_key_id" => "access_key",
            "aws_secret_access_key" => "secret_access_key",
            "aws_region" => "eu-west-2",
            "deploy_env" => "",
          },
          "syslog_drain_url" => nil,
          "volume_mounts" => [],
        },
        {
          "label" => "aws-s3-bucket",
          "provider" => nil,
          "plan" => "default",
          "name" => "dluhc-core-review-import-bucket",
          "tags" => %w[s3],
          "instance_guid" => "some-guid",
          "instance_name" => "dluhc-core-review-import-bucket",
          "binding_guid" => "some-guid",
          "binding_name" => nil,
          "credentials" => {
            "bucket_name" => "paas-s3-broker-prod-lon-some-guid",
            "aws_access_key_id" => "access_key",
            "aws_secret_access_key" => "secret_access_key",
            "aws_region" => "eu-west-2",
            "deploy_env" => "",
          },
          "syslog_drain_url" => nil,
          "volume_mounts" => [],
        },
      ],
      "postgres" => [
        {
          "label" => "postgres",
          "provider" => nil,
          "plan" => "some-plan",
          "name" => "dluhc-core-review-id-postgres",
          "tags" => %w[postgres relational],
          "instance_guid" => "some-guid",
          "instance_name" => "dluhc-core-review-id-postgres",
          "binding_guid" => "some-guid",
          "binding_name" => nil,
          "credentials" => {
            "host" => "rdsbroker-some-guid.some-guid.eu-west-2.rds.amazonaws.com",
            "port" => 5432,
            "name" => "rdsbroker_some_guid",
            "username" => "some_user",
            "password" => "some_password",
            "uri" => "postgres://some_user:some_password@rdsbroker-some-guid.some-guid.com:5432/rdsbroker_some_guid",
            "jdbcuri" => "some-connection-string",
            "syslog_drain_url" => nil,
            "volume_mounts" => [],
          },
        },
      ],
      "redis" => [
        {
          "label" => "redis",
          "provider" => nil,
          "plan" => "micro-6.x",
          "name" => "dluhc-core-review-id-redis",
          "tags" => %w[elasticache redis],
          "instance_guid" => "some-guid",
          "instance_name" => "dluhc-core-review-id-redis",
          "binding_guid" => "some-guid",
          "binding_name" => nil,
          "credentials" => {
            "host" => "somewhere.cache.amazonaws.com",
            "port" => 6379,
            "name" => "some-name",
            "password" => "some-password",
            "uri" => "rediss://key@master.cf-somewhere.euw2.cache.amazonaws.com:6379",
            "tls_enabled" => true,
          },
          "syslog_drain_url" => nil,
          "volume_mounts" => [],
        },
      ],
      "user-provided" => [
        {
          "label" => "user-provided",
          "name" => "logit-ssl-drain",
          "tags" => [],
          "instance_guid" => "some-guid",
          "instance_name" => "logit-ssl-drain",
          "binding_guid" => "some-guid",
          "binding_name" => nil,
          "credentials" => nil,
          "syslog_drain_url" => "syslog-tls://some-guid.service.com:123",
          "volume_mounts" => [],
        },
      ],
    }
  end

  before do
    stub_const("ENV", { "VCAP_SERVICES" => vcap_services.to_json })
  end

  describe "#credentials" do
    it "returns correct credentials" do
      expect(service.credentials[:aws_access_key_id]).to eql("access_key_123")
      expect(service.credentials[:aws_secret_access_key]).to eql("secret_access_key_123")
      expect(service.credentials[:bucket_name]).to eql("actual-export-bucket-name")
      expect(service.credentials[:aws_region]).to eql("region-1")
    end

    context "when bucket not present" do
      let(:name) { "foo" }

      it "raises an error" do
        expect { service.credentials[:aws_access_key_id] }.to raise_error.with_message("bucket: foo not found")
      end
    end
  end
end
