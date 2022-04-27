require "rails_helper"

RSpec.describe TabNavHelper do
  let(:organisation) { FactoryBot.create(:organisation) }
  let(:user) { FactoryBot.build(:user, organisation:) }

  describe "#user_cell" do
    it "returns user link and email separated by a newline character" do
      expected_html = "<a class=\"govuk-link govuk-!-font-weight-bold\" href=\"/users\">Danny Rojas</a>\n#{user.email}"
      expect(user_cell(user)).to match(expected_html)
    end
  end

  describe "#org_cell" do
    it "returns the users org name and role separated by a newline character" do
      expected_html = "DLUHC\n<span class='app-!-colour-muted'>Data provider</span>"
      expect(org_cell(user)).to match(expected_html)
    end
  end

  describe "#tab_items" do
    context "when user is a data_coordinator" do
      let(:user) { FactoryBot.build(:user, :data_coordinator, organisation:) }

      it "returns details and user tabs" do
        result = tab_items(user).map { |i| i[:name] }
        expect(result.count).to eq(2)
        expect(result.first).to match("Details")
        expect(result.second).to match("Users")
      end
    end

    context "when user is a data_provider" do
      it "returns details and user tabs" do
        result = tab_items(user).map { |i| i[:name] }
        expect(result.count).to eq(2)
        expect(result.first).to match("Details")
        expect(result.second).to match("Users")
      end
    end
  end
end
