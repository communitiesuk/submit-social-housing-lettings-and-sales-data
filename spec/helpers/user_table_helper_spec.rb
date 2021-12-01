require "rails_helper"

RSpec.describe UserTableHelper do
  let(:user) { FactoryBot.build(:user) }

  describe "#user_cell" do
    it "returns user link and email separated by a newline character" do
      expected_html = "<a class=\"govuk-link\" href=\"/users\">Danny Rojas</a>\n#{user.email}"
      expect(user_cell(user)).to match(expected_html)
    end
  end

  describe "#org_cell" do
    it "returns the users org name and role separated by a newline character" do
      expected_html = "DLUHC\n<span class='app-!-colour-muted'>Data Provider</span>"
      expect(org_cell(user)).to match(expected_html)
    end
  end
end
