require "rails_helper"

RSpec.describe ApplicationHelper do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
  let(:pagy) { nil }

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
