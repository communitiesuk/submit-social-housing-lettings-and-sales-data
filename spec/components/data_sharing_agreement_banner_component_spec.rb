require "rails_helper"

RSpec.describe DataSharingAgreementBannerComponent, type: :component do
  let(:component) { described_class.new(user:, organisation:) }
  let(:render) { render_inline(component) }
  let(:user) { create(:user) }
  let(:organisation) { user.organisation }

  context "when flag disabled" do
    before do
      allow(FeatureToggle).to receive(:new_data_sharing_agreement?).and_return(false)
    end

    it "does not display banner" do
      expect(component.display_banner?).to eq(false)
    end
  end

  context "when flag enabled" do
    before do
      allow(FeatureToggle).to receive(:new_data_sharing_agreement?).and_return(true)
    end

    context "when user is dpo" do
      let(:user) { create(:user, is_dpo: true) }

      it "does not display banner" do
        expect(component.display_banner?).to eq(false)
      end
    end

    context "when user is not support and not dpo" do
      let(:user) { create(:user) }

      context "when org blank" do
        let(:organisation) { nil }

        before do
          allow(DataSharingAgreement).to receive(:exists?).and_call_original
        end

        context "when data sharing agreement present" do
          it "does not display banner" do
            expect(component.display_banner?).to eq(false)
          end

          it "verifies DSA exists for organisation" do
            render
            expect(DataSharingAgreement).to have_received(:exists?).with(organisation: user.organisation)
          end
        end

        context "when data sharing agreement not present" do
          let(:user) { create(:user, organisation: create(:organisation, :without_dsa)) }

          it "displays the banner" do
            expect(component.display_banner?).to eq(true)
          end

          it "produces the correct link" do
            render
            expect(component.data_sharing_agreement_href).to eq("/organisations/#{user.organisation.id}/data-sharing-agreement")
          end

          it "verifies DSA exists for organisation" do
            render
            expect(DataSharingAgreement).to have_received(:exists?).with(organisation: user.organisation)
          end
        end
      end
    end

    context "when user is support" do
      let(:user) { create(:user, :support) }

      context "when org blank" do
        let(:organisation) { nil }

        it "does not display banner" do
          expect(component.display_banner?).to eq(false)
        end
      end

      context "when org present" do
        before do
          allow(DataSharingAgreement).to receive(:exists?).and_call_original
        end

        context "when data sharing agreement present" do
          it "does not display banner" do
            expect(component.display_banner?).to eq(false)
          end

          it "verifies DSA exists for organisation" do
            render
            expect(DataSharingAgreement).to have_received(:exists?).with(organisation:)
          end
        end

        context "when data sharing agreement not present" do
          let(:organisation) { create(:organisation, :without_dsa) }

          it "displays the banner" do
            expect(component.display_banner?).to eq(true)
          end

          it "produces the correct link" do
            render
            expect(component.data_sharing_agreement_href).to eq("/organisations/#{organisation.id}/data-sharing-agreement")
          end

          it "verifies DSA exists for organisation" do
            render
            expect(DataSharingAgreement).to have_received(:exists?).with(organisation:)
          end
        end
      end
    end
  end
end
