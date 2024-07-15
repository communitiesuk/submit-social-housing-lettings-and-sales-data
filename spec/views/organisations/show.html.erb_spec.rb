require "rails_helper"

RSpec.describe "organisations/show.html.erb" do
  before do
    allow(view).to receive(:current_user).and_return(user)
    assign(:organisation, user.organisation)
  end

  let(:fragment) { Capybara::Node::Simple.new(rendered) }
  let(:organisation_without_dpc) { create(:organisation, :without_dpc) }
  let(:organisation_with_dsa) { create(:organisation) }

  context "when dpo" do
    let(:user) { create(:user, is_dpo: true, organisation: organisation_without_dpc, with_dsa: false) }

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

      expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation_without_dpc.id}/data-sharing-agreement")
    end

    context "when accepted" do
      let(:user) { create(:user, organisation: organisation_with_dsa, with_dsa: false) }

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

        expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation_with_dsa.id}/data-sharing-agreement")
      end
    end
  end

  context "when support user" do
    let(:user) { create(:user, :support, organisation: organisation_without_dpc, with_dsa: false) }

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

      expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation_without_dpc.id}/data-sharing-agreement")
    end

    context "when accepted" do
      let(:user) { create(:user, :support, organisation: organisation_with_dsa, with_dsa: false) }

      it "includes data sharing agreement row" do
        render

        expect(fragment).to have_content("Data Sharing Agreement")
      end

      it "shows data sharing agreement accepted with date" do
        render

        expect(fragment).to have_content("Accepted 04/02/2022")
      end

      it "shows show name of who signed the agreement" do
        render

        expect(fragment).to have_content(user.organisation.data_protection_confirmation.data_protection_officer.name)
      end

      it "shows link to view data sharing agreement" do
        render

        expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation_with_dsa.id}/data-sharing-agreement")
      end
    end

    it "shows deactivate button when organisation is active" do
      user.organisation.active = true
      render
      expect(fragment).to have_content("Deactivate this organisation")
      expect(fragment).not_to have_content("Reactivate this organisation")
    end

    it "shows reactivate button when organisation is inactive" do
      user.organisation.active = false
      render
      expect(fragment).not_to have_content("Deactivate this organisation")
      expect(fragment).to have_content("Reactivate this organisation")
    end
  end

  context "when not dpo" do
    let(:user) { create(:user, organisation: organisation_without_dpc, with_dsa: false) }

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
      expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation_without_dpc.id}/data-sharing-agreement")
    end

    context "when accepted" do
      let(:user) { create(:user, organisation: organisation_with_dsa, with_dsa: false) }

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
        expect(fragment).to have_link(text: "View agreement", href: "/organisations/#{organisation_with_dsa.id}/data-sharing-agreement")
      end
    end
  end
end
