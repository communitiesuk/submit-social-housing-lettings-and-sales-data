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
    before do
      Excon.defaults[:mock] = true
      Excon.defaults[:stubs] = :local
    end

    context "when the request returns a success response" do
      before do
        Excon.stub({}, { body: '{"result": { "admin_district": "District", "codes": { "admin_district": "123" } } }', status: 200 })
      end

      it "returns the admin district and admin district code" do
        result = service.lookup("A00 0AA")
        expect(result[:location_code]).to eq("123")
        expect(result[:location_admin_district]).to eq("District")
      end
    end

    context "when the request returns a not found response" do
      before do
        Excon.stub({}, { status: 404 })
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
        Excon.stub({}, { body: "This is an error message that is not valid json", status: 500 })
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
  end
end
