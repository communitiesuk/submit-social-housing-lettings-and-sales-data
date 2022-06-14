require "rails_helper"

RSpec.describe ApplicationHelper do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
  let(:pagy) { nil }
  let(:current_user) { FactoryBot.create(:user) }

  describe "govuk_header_classes" do
    context "with external user" do
      it "shows the standard app header" do
        expect(govuk_header_classes(current_user)).to eq("app-header")
      end
    end

    context "with internal support user" do
      let(:current_user) { FactoryBot.create(:user, :support) }

      it "shows an orange header" do
        expect(govuk_header_classes(current_user)).to eq("app-header app-header--orange")
      end
    end
  end

  describe "govuk_phase_banner_tag" do
    context "with external user" do
      it "shows the standard phase tag" do
        expect(govuk_phase_banner_tag(current_user)).to eq({ text: "Beta" })
      end
    end

    context "with support user" do
      let(:current_user) { FactoryBot.create(:user, :support) }

      it "shows an orange phase tag" do
        expect(govuk_phase_banner_tag(current_user)).to eq({
          colour: "orange",
          text: "Support beta",
        })
      end
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
