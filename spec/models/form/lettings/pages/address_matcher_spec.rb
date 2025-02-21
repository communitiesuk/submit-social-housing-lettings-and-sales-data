require "rails_helper"

RSpec.describe Form::Lettings::Pages::AddressMatcher, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { Form.new(nil, 2024, [], "lettings") }
  let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true, depends_on: nil) }
  let(:log) { build(:lettings_log) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_line1_input postcode_full_input])
  end

  it "has the correct id" do
    expect(page.id).to eq("address_matcher")
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

    context "when uprn_known is 1 and uprn_confirmed is not 0" do
      let(:log) { build(:lettings_log, uprn_known: 1, uprn: "1", uprn_confirmed: 1) }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is nil and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_known: nil) }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is 0 and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_known: 0) }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_confirmed is 0 and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0) }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when it is a new build in 2025" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn_known: nil, rsnvac: 15, startdate: Time.zone.local(2025, 5, 5)) }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when it is a new build in 2024" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn_known: nil, rsnvac: 15, startdate: Time.zone.local(2024, 5, 5)) }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end
  end

  it "has the correct skip_href" do
    expect(page.skip_href(log)).to eq(
      "/lettings-logs/#{log.id}/property-unit-type",
    )
  end
end
