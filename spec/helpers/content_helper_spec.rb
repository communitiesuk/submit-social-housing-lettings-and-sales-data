require "rails_helper"

RSpec.describe ContentHelper do
  let(:page_name) { "privacy_notice" }

  describe "render content page" do
    it "returns the page" do
      expected_html = "Privacy notice"
      expect(render_content_page(page_name)).to match(expected_html)
      expect(page).to have_title("Privacy notice")
    end
  end
end
