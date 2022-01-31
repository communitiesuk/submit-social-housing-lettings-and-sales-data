require "rails_helper"

RSpec.describe "PaasConfigurationService" do
  context "when the paas configuration is unavailable" do
    subject { PaasConfigurationService.new(logger) }

    let(:logger) { double("logger") }

    before { allow(logger).to receive(:warn) }

    it "returns the configuration as not present" do
      expect(subject.config_present?).to be(false)
    end

    it "returns the S3 configuration as not present" do
      expect(subject.s3_config_present?).to be(false)
    end

    it "does not retrieve any S3 bucket configuration" do
      expect(subject.s3_buckets).to be_empty
    end
  end

  context "when the paas configuration is present with S3 buckets" do
    subject { PaasConfigurationService.new(double("logger")) }

    let(:vcap_services) do
      <<-JSON
        {"aws-s3-bucket": [{"instance_name": "bucket_1"},{"instance_name": "bucket_2"}]}
      JSON
    end

    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return(vcap_services)
    end

    it "returns the configuration as present" do
      expect(subject.config_present?).to be(true)
    end

    it "returns the S3 configuration as present" do
      expect(subject.s3_config_present?).to be(true)
    end

    it "does retrieve the S3 bucket configurations" do
      s3_buckets = subject.s3_buckets

      expect(s3_buckets).not_to be_empty
      expect(s3_buckets.count).to be(2)
      expect(s3_buckets).to have_key(:bucket_1)
      expect(s3_buckets).to have_key(:bucket_2)
    end
  end

  context "when the paas configuration is present without S3 buckets" do
    subject { PaasConfigurationService.new(double("logger")) }

    before do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("{}")
    end

    it "returns the configuration as present" do
      expect(subject.config_present?).to be(true)
    end

    it "returns the S3 configuration as not present" do
      expect(subject.s3_config_present?).to be(false)
    end

    it "does not retrieve any S3 bucket configuration" do
      expect(subject.s3_buckets).to be_empty
    end
  end
end
