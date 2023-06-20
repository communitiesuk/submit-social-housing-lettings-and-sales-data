require "rails_helper"

RSpec.describe DataProtectionConfirmationBannerComponent, type: :component do
  include GovukComponent

  let(:component) { described_class.new(user:, organisation:) }
  let(:render) { render_inline(component) }
  let(:user) { create(:user) }
  let(:organisation) { user.organisation }

  context "when flag disabled" do
    before do
      allow(FeatureToggle).to receive(:new_data_protection_confirmation?).and_return(false)
    end

    it "does not display banner" do
      expect(component.display_banner?).to eq(false)
      expect(render.content).to be_empty
    end
  end

  context "when flag enabled", :aggregate_failures do
    before do
      allow(FeatureToggle).to receive(:new_data_protection_confirmation?).and_return(true)
    end

    context "when user is support and organisation is blank" do
      let(:user) { create(:user, :support) }
      let(:organisation) { nil }

      it "does not display banner" do
        expect(component.display_banner?).to eq(false)
        expect(render.content).to be_empty
      end
    end

    context "when org does not have a DPO" do
      before do
        organisation.users.where(is_dpo: true).destroy_all
      end

      it "displays the banner" do
        expect(component.display_banner?).to eq(true)
        expect(render).to have_link(
          "Contact helpdesk to assign a data protection officer",
          href: "https://digital.dclg.gov.uk/jira/servicedesk/customer/portal/4/group/21",
        )
        expect(render).to have_selector("p", text: "To create logs your organisation must state a data protection officer. They must sign the Data Sharing Agreement.")
      end
    end

    context "when org has a DPO" do
      context "when org does not have a signed data sharing agreement" do
        context "when user is not a DPO" do
          let(:organisation) { create(:organisation, :without_dpc) }
          let(:user) { create(:user, organisation:) }
          let!(:dpo) { create(:user, :data_protection_officer, organisation:) }

          it "displays the banner and shows DPOs" do
            expect(component.display_banner?).to eq(true)
            expect(render.css("a")).to be_empty
            expect(render).to have_selector("p", text: "Your data protection officer must accept the Data Sharing Agreement on CORE before you can create any logs.")
            expect(render).to have_selector("p", text: "You can ask: #{dpo.name}")
          end
        end

        context "when user is a DPO" do
          let(:organisation) { create(:organisation, :without_dpc) }
          let(:user) { create(:user, :data_protection_officer, organisation:) }

          it "displays the banner and asks to sign" do
            expect(component.display_banner?).to eq(true)
            expect(render).to have_link(
              "Read the Data Sharing Agreement",
              href: "/organisations/#{organisation.id}/data-sharing-agreement",
            )
            expect(render).to have_selector("p", text: "Your organisation must accept the Data Sharing Agreement before you can create any logs.")
          end
        end
      end

      context "when org has a signed data sharing agremeent" do
        it "does not display banner" do
          expect(component.display_banner?).to eq(false)
          expect(render.content).to be_empty
        end
      end
    end
  end
end
