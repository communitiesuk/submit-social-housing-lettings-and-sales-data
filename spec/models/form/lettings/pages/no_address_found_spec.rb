require "rails_helper"

RSpec.describe Form::Lettings::Pages::NoAddressFound, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { Form.new(nil, 2024, [], "lettings") }
  let(:subsection) { instance_double(Form::Subsection, form:, enabled?: true, depends_on: nil) }
  let(:log) { create(:lettings_log) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_search_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("no_address_found")
  end

  describe "routed_to?" do
    context "when it is supported housing" do
      let(:log) { build(:lettings_log, :sh) }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when address_options_present?" do
      let(:log) { build(:lettings_log, address_line1_input: "Address", postcode_full_input: "A11AA") }

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
      let(:log) { build(:lettings_log, uprn_known: nil, uprn_selection: "uprn_not_listed") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_known is 0 and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_known: 0, uprn_selection: "uprn_not_listed") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when uprn_confirmed is 0 and address_options_present? is false" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn_selection: "uprn_not_listed") }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end

    context "when it is a new build in 2025" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn_selection: "uprn_not_listed", rsnvac: 15, startdate: Time.zone.local(2025, 5, 5)) }

      it "does not route to the page" do
        expect(page).not_to be_routed_to(log, nil)
      end
    end

    context "when it is a new build in 2024" do
      let(:log) { build(:lettings_log, uprn_confirmed: 0, uprn_selection: "uprn_not_listed", rsnvac: 15, startdate: Time.zone.local(2024, 5, 5)) }

      it "routes to the page" do
        expect(page).to be_routed_to(log, nil)
      end
    end
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({ "arguments" => [], "translation" => "forms.2024.lettings.soft_validations.no_address_found.title_text" })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({ "arguments" => [], "translation" => "forms.2024.lettings.soft_validations.no_address_found.informative_text" })
  end

  it "has the correct interruption_screen_question_ids" do
    expect(page.interruption_screen_question_ids).to eq(%w[address_line1_input])
  end
end
