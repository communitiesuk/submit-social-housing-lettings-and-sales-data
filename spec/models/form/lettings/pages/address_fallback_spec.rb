require "rails_helper"

RSpec.describe Form::Lettings::Pages::AddressFallback, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { Form.new(nil, 2024, [], "lettings") }
  let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true, depends_on:nil) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_line1 address_line2 town_or_city county postcode_full])
  end

  it "has the correct id" do
    expect(page.id).to eq("address")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  describe "routed_to?" do
    context "when it is supported housing" do
      let(:log) { build(:lettings_log, :sh) }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is nil and uprn_selection is uprn_not_listed" do
      let(:log) { build(:lettings_log, uprn_known: nil, uprn_selection: "uprn_not_listed") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is 0 and uprn_selection is uprn_not_listed" do
      let(:log) { build(:lettings_log, uprn_known: 0, uprn_selection: "uprn_not_listed") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_confirmed is 0 and uprn_selection is uprn_not_listed" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn_selection: "uprn_not_listed") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is nil and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_known: nil, uprn: "1999") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is 0 and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_known: 0, uprn: "1999") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_confirmed is 0 and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn: "1999") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when address_options_present? is true and uprn_selection is not uprn_not_listed" do
      let(:log) { build(:lettings_log, uprn_selection: nil, uprn: "1", address_line1_input: "Address", postcode_full_input: "A11AA") }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is 1 and uprn_confirmed is not 0" do
      let(:log) { build(:lettings_log, uprn_known: 1, uprn: "1", uprn_confirmed: 1) }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end
  end
end
