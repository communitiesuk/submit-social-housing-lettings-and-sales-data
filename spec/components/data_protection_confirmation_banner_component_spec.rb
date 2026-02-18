require "rails_helper"

RSpec.describe DataProtectionConfirmationBannerComponent, type: :component do
  include GovukComponent

  let(:component) { described_class.new(user:, organisation:) }
  let(:render) { render_inline(component) }
  let(:user) { create(:user, with_dsa: false) }
  let(:organisation) { user.organisation }

  context "when user is support and organisation is blank" do
    let(:user) { create(:user, :support, with_dsa: false) }
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

    context "when org does not have a signed data sharing agreement" do
      let(:organisation) { create(:organisation, :without_dpc) }
      let(:user) { create(:user, organisation:, with_dsa: false) }

      it "displays the banner" do
        expect(component.display_banner?).to eq(true)
        expect(render).to have_link(
          "Contact helpdesk to assign a data protection officer",
          href: "https://mhclgdigital.atlassian.net/servicedesk/customer/portal/6/group/11",
        )
        expect(render).to have_selector("p", text: "To create logs your organisation must state a data protection officer. They must sign the Data Sharing Agreement.")
      end
    end

    context "when org does have a signed data sharing agreement" do
      it "does not display banner" do
        expect(component.display_banner?).to eq(false)
        expect(render.content).to be_empty
      end
    end
  end

  context "when org has a DPO" do
    context "when org does not have a signed data sharing agreement" do
      context "when user is not a DPO" do
        let(:organisation) { create(:organisation, :without_dpc) }
        let(:user) { create(:user, organisation:, with_dsa: false) }
        let!(:dpo) { create(:user, :data_protection_officer, organisation:, with_dsa: false) }

        it "displays the banner and shows DPOs" do
          expect(component.display_banner?).to eq(true)
          expect(render.css("a")).to be_empty
          expect(render).to have_selector("p", text: "Your data protection officer must accept the Data Sharing Agreement on CORE before you can create any logs.")
          expect(render).to have_selector("p", text: "You can ask: #{dpo.name}")
        end
      end

      context "when user is a DPO" do
        let(:organisation) { create(:organisation, :without_dpc) }
        let(:user) { create(:user, :data_protection_officer, organisation:, with_dsa: false) }

        it "displays the banner and asks to sign" do
          expect(component.display_banner?).to eq(true)
          expect(render).to have_link(
            "Read the Data Sharing Agreement",
            href: "/organisations/#{organisation.id}/data-sharing-agreement",
          )
          expect(render).to have_selector("p", text: "Your organisation must accept the Data Sharing Agreement before you can create any logs.")
        end
      end

      context "and org doesn't own stock and has a parent organisation that hasn't signed DSA" do
        before do
          organisation.data_protection_confirmation.update!(confirmed: false)
          organisation.update!(holds_own_stock: false)
          parent_organisation = create(:organisation, :without_dpc, holds_own_stock: true)
          create(:organisation_relationship, child_organisation: organisation, parent_organisation:)
        end

        it "displays the banner and asks to sign" do
          expect(component.display_banner?).to eq(true)
          expect(render).to have_link(
            "Read the Data Sharing Agreement",
            href: "/organisations/#{organisation.id}/data-sharing-agreement",
          )
          expect(render).to have_selector("p", text: "Your data protection officer must accept the Data Sharing Agreement on CORE before you can create any logs.")
        end
      end
    end

    context "when org has a signed data sharing agreement" do
      it "does not display banner" do
        expect(component.display_banner?).to eq(false)
        expect(render.content).to be_empty
      end

      context "and doesn't own stock" do
        before do
          organisation.update!(holds_own_stock: false)
        end

        context "and has a parent organisation that owns stock and has signed DSA" do
          before do
            parent_organisation = create(:organisation, holds_own_stock: true)
            create(:organisation_relationship, child_organisation: organisation, parent_organisation:)
          end

          it "does not display banner" do
            expect(component.display_banner?).to eq(false)
            expect(render.content).to be_empty
          end
        end

        context "and has a parent organisation that hasn't signed DSA" do
          before do
            parent_organisation = create(:organisation, :without_dpc, holds_own_stock: true)
            create(:organisation_relationship, child_organisation: organisation, parent_organisation:)
          end

          it "displays the banner and asks to create stock owners" do
            expect(component.display_banner?).to eq(true)
            expect(render).to have_link(
              "View or add stock owners",
              href: "/organisations/#{organisation.id}/stock-owners",
            )
            expect(render).to have_selector("p", text: "Your organisation does not own stock. To create logs your stock owner(s) must accept the Data Sharing Agreement on CORE.")
          end
        end
      end
    end
  end
end
