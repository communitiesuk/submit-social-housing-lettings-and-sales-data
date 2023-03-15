require "rails_helper"

describe UprnClient do
  let(:client) { described_class.new("123") }

  let(:valid_response) do
    { results: [{ DPA: { postcode: "12345" } }] }.to_json
  end

  def stub_api_request(body:, status: 200)
    stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123")
    .to_return(status:, body:, headers: {})
  end

  describe "call" do
    context "when json parse error" do
      before do
        stub_api_request(body: "{", status: 200)

        client.call
      end

      it "returns error" do
        expect(client.error).to eq("UPRN is not recognised. Check the number, or enter the address")
      end
    end

    context "when http error" do
      before do
        stub_api_request(body: valid_response, status: 500)

        client.call
      end

      it "returns error" do
        expect(client.error).to eq("UPRN is not recognised. Check the number, or enter the address")
      end
    end

    context "when results empty" do
      before do
        stub_api_request(body: {}.to_json)

        client.call
      end

      it "returns error" do
        expect(client.error).to eq("UPRN is not recognised. Check the number, or enter the address")
      end
    end

    context "with results" do
      before do
        stub_api_request(body: valid_response)

        client.call
      end

      it "returns result" do
        expect(client.result).to eq({ "postcode" => "12345" })
      end

      it "returns no error" do
        expect(client.error).to be_nil
      end
    end
  end
end
