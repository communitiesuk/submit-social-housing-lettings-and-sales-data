require "rails_helper"

RSpec.describe ApplicationHelper do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
  let(:pagy) { nil }

  describe "govuk_header_classes" do
    context "with external user" do
      expect(govuk_header_classes) .to eq("app-header")
    end

    context "with internal support user" do
      let(:current_user) { FactoryBot.create(:user, :support) }
      expect(govuk_header_classes) .to eq("app-header app-header--orange")
    end
  end

  describe "govuk_phase_banner_tag" do
    context "with external user" do
      expect(govuk_phase_banner_tag) .to eq({
        text: "Beta",
      })
    end

    context "with support user" do
      let(:current_user) { FactoryBot.create(:user, :support) }
      expect(govuk_phase_banner_tag) .to eq({
        colour: "orange",
        text: "Support beta",
      })
    end
  end

  describe "browser_title" do
    context "with no pagination" do
      it "returns correct browser title when title is given" do
        expect(browser_title("title", pagy))
          .to eq("title - #{t('service_name')} - GOV.UK")
      end

      it "returns correct browser title when title is not given" do
        expect(browser_title(nil, pagy))
          .to eq("#{t('service_name')} - GOV.UK")
      end
    end

    context "with pagination" do
      let(:pagy) { OpenStruct.new(page: 1, pages: 2) }

      it "returns correct browser title when title is given" do
        expect(browser_title("title", pagy))
          .to eq("title (page 1 of 2) - #{t('service_name')} - GOV.UK")
      end

      it "returns correct browser title when title is not given" do
        expect(browser_title(nil, pagy))
          .to eq("#{t('service_name')} - GOV.UK")
      end
    end
  end
end
