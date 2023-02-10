require "rails_helper"

RSpec.describe InterruptionScreenHelper do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:subsection) { form.get_subsection("household_characteristics") }
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      ecstat1: 1,
      earnings: 750,
      incfreq: 1,
      created_by: user,
      sex1: "F",
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
        expect(display_informative_text(informative_text, lettings_log))
          .to eq(I18n.t("soft_validations.net_income.hint_text", ecstat1: lettings_log.form.get_question("ecstat1", lettings_log).answer_label(lettings_log).downcase, earnings: lettings_log.form.get_question("earnings", lettings_log).answer_label(lettings_log)))
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
        expect(display_informative_text(informative_text, lettings_log))
          .to eq(I18n.t("test.one_argument", ecstat1: lettings_log.form.get_question("ecstat1", lettings_log).answer_label(lettings_log).downcase))
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
        expect(display_informative_text(informative_text, lettings_log))
          .to eq(I18n.t("test.one_argument", ecstat1: lettings_log.form.get_question("ecstat1", lettings_log).answer_label(lettings_log).downcase))
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
        expect(display_informative_text(informative_text, lettings_log))
          .to eq("")
      end
    end

    context "when an argument is given not for a label" do
      translation = "test.title_text.one_argument"
      it "returns the correct text" do
        informative_text_hash = {
          "translation" => translation,
          "arguments" => [
            {
              "key" => "earnings",
              "i18n_template" => "argument",
            }
          ]
        }
        expect(display_informative_text(informative_text_hash, lettings_log)).to eq(I18n.t(translation, argument: lettings_log.earnings))
      end
    end

    context "when and argument is given with a key and arguments for the key" do
      it "makes the correct method call" do
        informative_text_hash = {
          "arguments" => [
            {
              "key" => "retirement_age_for_person",
              "arguments_for_key" => 1,
              "i18n_template" => "argument",
            }
          ]
        }
        allow(lettings_log).to receive(:retirement_age_for_person)
        display_informative_text(informative_text_hash, lettings_log)
        expect(lettings_log).to have_received(:retirement_age_for_person).with(1)
      end

      it "returns the correct text" do
        translation = "test.title_text.one_argument"
        informative_text_hash = {
          "translation" => translation,
          "arguments" => [
            {
              "key" => "retirement_age_for_person",
              "arguments_for_key" => 1,
              "i18n_template" => "argument",
            }
          ]
        }
        expect(display_informative_text(informative_text_hash, lettings_log)).to eq(I18n.t(translation, argument: lettings_log.retirement_age_for_person(1)))
      end
    end
  end

  describe "display_title_text" do
    context "when title text has no arguments" do
      it "returns the correct title text" do
        title_text = { "translation" => "test.title_text.no_argument" }
        expect(display_title_text(title_text, lettings_log))
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
              "i18n_template" => "argument",
            },
          ],
        }
        expect(display_title_text(title_text, lettings_log))
          .to eq(I18n.t("test.title_text.one_argument", argument: lettings_log.form.get_question("ecstat1", lettings_log).answer_label(lettings_log).downcase))
      end
    end

    context "when title text is not defined" do
      it "returns an empty string" do
        expect(display_title_text(nil, lettings_log)).to eq("")
      end
    end

    context "when title text is empty string" do
      it "returns an empty string" do
        expect(display_title_text("", lettings_log)).to eq("")
      end
    end
  end
end
