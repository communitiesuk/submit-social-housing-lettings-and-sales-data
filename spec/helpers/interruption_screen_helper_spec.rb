require "rails_helper"

RSpec.describe InterruptionScreenHelper do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      ecstat1: 1,
      earnings: 750,
      incfreq: 1,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end

  describe "display_informative_text" do
    context "when 2 out of 2 arguments are given" do
      it "returns correct informative text" do
        informative_text = {
          "translation" => "soft_validations.net_income.hint_text",
          "arguments" => [
            {
              "key" => "ecstat1",
              "label" => true,
              "i18n_template" => "ecstat1",
            },
            {
              "key" => "earnings",
              "label" => true,
              "i18n_template" => "earnings",
            },
          ],
        }
        expect(display_informative_text(informative_text, case_log))
          .to eq(I18n.t("soft_validations.net_income.hint_text", ecstat1: case_log.form.get_question("ecstat1", case_log).answer_label(case_log).downcase, earnings: case_log.form.get_question("earnings", case_log).answer_label(case_log)))
      end
    end

    context "when 1 out of 1 arguments is given" do
      it "returns correct informative text" do
        informative_text = {
          "translation" => "test.one_argument",
          "arguments" => [
            {
              "key" => "ecstat1",
              "label" => true,
              "i18n_template" => "ecstat1",
            },
          ],
        }
        expect(display_informative_text(informative_text, case_log))
          .to eq(I18n.t("test.one_argument", ecstat1: case_log.form.get_question("ecstat1", case_log).answer_label(case_log).downcase))
      end
    end

    context "when 2 out of 1 arguments are given" do
      it "returns correct informative text" do
        informative_text = {
          "translation" => "test.one_argument",
          "arguments" => [
            {
              "key" => "ecstat1",
              "label" => true,
              "i18n_template" => "ecstat1",
            },
            {
              "key" => "earnings",
              "label" => true,
              "i18n_template" => "earnings",
            },
          ],
        }
        expect(display_informative_text(informative_text, case_log))
          .to eq(I18n.t("test.one_argument", ecstat1: case_log.form.get_question("ecstat1", case_log).answer_label(case_log).downcase))
      end
    end

    context "when 1 out of 2 arguments are given" do
      it "returns an empty string" do
        informative_text = {
          "translation" => "soft_validations.net_income.hint_text",
          "arguments" => [
            {
              "key" => "ecstat1",
              "label" => true,
              "i18n_template" => "ecstat1",
            },
          ],
        }
        expect(display_informative_text(informative_text, case_log))
          .to eq("")
      end
    end
  end

  describe "display_title_text" do
    context "when title text has no arguments" do
      it "returns the correct title text" do
        title_text = "test.title_text.no_argument"
        expect(display_title_text(title_text, case_log))
          .to eq(I18n.t("test.title_text.no_argument"))
      end
    end
    
    context "when title text has arguments" do
      it "returns the correct title text" do
        title_text = {
          "translation" => "test.title_text.one_argument",
          "arguments" => [
            {
              "key" => "ecstat1",
              "label" => true,
              "i18n_template" => "ecstat1",
            },
          ],
        }
        expect(display_title_text(title_text, case_log))
          .to eq(I18n.t("test.title_text.one_argument", ecstat1: case_log.form.get_question("ecstat1", case_log).answer_label(case_log).downcase))
      end
    end 
  end
end
