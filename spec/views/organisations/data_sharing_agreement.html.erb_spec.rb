require "rails_helper"

RSpec.describe "organisations/data_sharing_agreement.html.erb" do
  before do
    Timecop.freeze(Time.zone.local(2023, 1, 10))
    allow(view).to receive(:current_user).and_return(user)
    assign(:organisation, organisation)
    assign(:data_sharing_agreement, data_sharing_agreement)
  end

  after do
    Timecop.return
  end

  let(:fragment) { Capybara::Node::Simple.new(rendered) }
  let(:organisation) { user.organisation }
  let(:data_sharing_agreement) { nil }

  context "when dpo" do
    let(:user) { create(:user, is_dpo: true) }

    it "shows current date" do
      render
      expect(fragment).to have_content("10th day of January 2023")
    end

    it "shows dpo name" do
      render
      expect(fragment).to have_content("Name: #{user.name}")
    end

    it "shows action buttons" do
      render
      expect(fragment).to have_button(text: "Accept this agreement")
      expect(fragment).to have_link(text: "Cancel", href: "/organisations/#{organisation.id}/details")
    end

    context "when accepted" do
      let(:data_sharing_agreement) do
        DataSharingAgreement.create!(
          organisation:,
          signed_at: Time.zone.now - 1.day,
          data_protection_officer: user,
        )
      end

      it "does not show action buttons" do
        render

        expect(fragment).not_to have_button(text: "Accept this agreement")
        expect(fragment).not_to have_link(text: "Cancel", href: "/organisations/#{organisation.id}/details")
      end

      it "sees signed_at date" do
        render
        expect(fragment).to have_content("9th day of January 2023")
      end

      it "shows dpo name" do
        render
        expect(fragment).to have_content("Name: #{user.name}")
      end
    end
  end

  context "when not dpo" do
    let(:user) { create(:user) }

    it "shows DPO placeholder" do
      render
      expect(fragment).to have_content("Name: [DPO name]")
    end

    it "shows placeholder date" do
      render
      expect(fragment).to have_content("This agreement is made the [XX] day of [XX] 20[XX]")
    end

    it "does not show action buttons" do
      render
      expect(fragment).not_to have_button(text: "Accept this agreement")
      expect(fragment).not_to have_link(text: "Cancel", href: "/organisations/#{organisation.id}/details")
    end

    context "when accepted" do
      let(:data_sharing_agreement) do
        DataSharingAgreement.create!(
          organisation:,
          signed_at: Time.zone.now - 1.day,
          data_protection_officer: user,
        )
      end

      it "does not show action buttons" do
        render
        expect(fragment).not_to have_button(text: "Accept this agreement")
        expect(fragment).not_to have_link(text: "Cancel", href: "/organisations/#{organisation.id}/details")
      end

      it "sees signed_at date" do
        render
        expect(fragment).to have_content("9th day of January 2023")
      end

      it "shows dpo name" do
        render
        expect(fragment).to have_content("Name: #{user.name}")
      end
    end
  end
end
