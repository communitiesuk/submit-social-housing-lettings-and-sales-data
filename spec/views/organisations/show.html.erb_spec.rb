require "rails_helper"

RSpec.describe "organisations/show.html.erb" do
  before do
    Timecop.freeze(Time.zone.local(2023, 1, 10))
    allow(view).to receive(:current_user).and_return(user)
    assign(:organisation, organisation)
    organisation.update!(data_sharing_agreement:)
  end

  after do
    Timecop.return
  end

  let(:fragment) { Capybara::Node::Simple.new(rendered) }
  let(:organisation) { user.organisation }
  let(:data_sharing_agreement) { nil }

  context "when flag disabled" do
    let(:user) { create(:user) }

    before do
      allow(FeatureToggle).to receive(:new_data_sharing_agreement?).and_return(false)
    end

    it "does not include data sharing agreement row" do
      render

      expect(fragment).not_to have_content("Data Sharing Agreement")
    end
  end

  context "when dpo" do
    let(:user) { create(:user, is_dpo: true) }

    it "includes data sharing agreement row" do
      render

      expect(fragment).to have_content("Data Sharing Agreement")
    end

    it "shows data sharing agreement not accepted" do
      render

      expect(fragment).to have_content("Not accepted")
    end

    it "shows link to view data sharing agreement" do
      render

      expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation.id}/data-sharing-agreement")
    end

    context "when accepted" do
      let(:data_sharing_agreement) do
        DataSharingAgreement.create!(
          organisation:,
          signed_at: Time.zone.now - 1.day,
          data_protection_officer: user,
        )
      end

      it "includes data sharing agreement row" do
        render

        expect(fragment).to have_content("Data Sharing Agreement")
      end

      it "shows data sharing agreement accepted" do
        render

        expect(fragment).to have_content("Accepted")
      end

      it "shows link to view data sharing agreement" do
        render

        expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation.id}/data-sharing-agreement")
      end
    end
  end

  context "when support user" do
    let(:user) { create(:user, :support) }

    it "includes data sharing agreement row" do
      render

      expect(fragment).to have_content("Data Sharing Agreement")
    end

    it "shows data sharing agreement not accepted" do
      render

      expect(fragment).to have_content("Not accepted")
    end

    it "tells DPO must sign" do
      render

      expect(fragment).to have_content("Data protection officer must sign")
    end

    it "shows link to view data sharing agreement" do
      render

      expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation.id}/data-sharing-agreement")
    end

    context "when accepted" do
      let(:dpo) { create(:user, is_dpo: true) }
      let(:data_sharing_agreement) do
        DataSharingAgreement.create!(
          organisation:,
          signed_at: Time.zone.now - 1.day,
          data_protection_officer: dpo,
        )
      end

      it "includes data sharing agreement row" do
        render

        expect(fragment).to have_content("Data Sharing Agreement")
      end

      it "shows data sharing agreement accepted with date" do
        render

        expect(fragment).to have_content("Accepted 09/01/2023")
      end

      it "shows show name of who signed the agreement" do
        render

        expect(fragment).to have_content(dpo.name)
      end

      it "shows link to view data sharing agreement" do
        render

        expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation.id}/data-sharing-agreement")
      end
    end
  end

  context "when not dpo" do
    let(:user) { create(:user) }

    it "includes data sharing agreement row" do
      render

      expect(fragment).to have_content("Data Sharing Agreement")
    end

    it "shows data sharing agreement not accepted" do
      render
      expect(fragment).to have_content("Not accepted")
    end

    it "tells DPO must sign" do
      render
      expect(fragment).to have_content("Data protection officer must sign")
    end

    it "shows link to view data sharing agreement" do
      render
      expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation.id}/data-sharing-agreement")
    end

    context "when accepted" do
      let(:data_sharing_agreement) do
        DataSharingAgreement.create!(
          organisation:,
          signed_at: Time.zone.now - 1.day,
          data_protection_officer: user,
        )
      end

      it "includes data sharing agreement row" do
        render

        expect(fragment).to have_content("Data Sharing Agreement")
      end

      it "shows data sharing agreement accepted" do
        render
        expect(fragment).to have_content("Accepted")
      end

      it "shows link to view data sharing agreement" do
        render
        expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation.id}/data-sharing-agreement")
      end
    end
  end
end
