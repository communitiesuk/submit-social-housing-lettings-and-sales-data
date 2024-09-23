require "rails_helper"

describe PostcodeService do
  let(:service) { described_class.new }

  describe "clean" do
    let(:postcode) { "s r81LS\u00A0" }

    it "returns clean postcode" do
      expect(described_class.clean(postcode)).to eq "SR81LS"
    end
  end

  describe "lookup" do
    context "when the request returns a success response" do
      before do
        WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/A000AA")
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"A00 0AA\",\"admin_district\":\"District\",\"codes\":{\"admin_district\":\"123\"}}}", headers: {})
      end

      it "returns the admin district and admin district code" do
        result = service.lookup("A00 0AA")
        expect(result[:location_code]).to eq("123")
        expect(result[:location_admin_district]).to eq("District")
      end
    end

    context "when the request returns a not found response" do
      before do
        WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/A000AA")
        .to_return(status: 404, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
      end

      it "returns nil" do
        result = service.lookup("A00 0AA")
        expect(result).to be_nil
      end

      it "logs the error at warning level" do
        expect(Rails.logger).to receive(:warn).with(match "404 Not Found")
        service.lookup("A00 0AA")
      end
    end

    context "when the request returns an error response" do
      before do
        WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/A000AA")
        .to_return(status: 500, body: "This is an error message that is not valid json", headers: {})
      end

      it "returns nil" do
        result = service.lookup("A00 0AA")
        expect(result).to be_nil
      end

      it "logs the error at warning level" do
        expect(Rails.logger).to receive(:warn).with(match "This is an error message that is not valid json")
        service.lookup("A00 0AA")
      end
    end

    context "when the request returns a success response that causes later errors" do
      before do
        WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/A000AA")
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Westminster\"", headers: {})
      end

      it "returns nil" do
        result = service.lookup("A00 0AA")
        expect(result).to be_nil
      end

      it "logs the error at error level" do
        expect(Rails.logger).to receive(:error).with(match "Unexpected error with postcode lookup request")
        service.lookup("A00 0AA")
      end
    end
  end
end
