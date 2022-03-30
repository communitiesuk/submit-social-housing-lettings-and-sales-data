require "rails_helper"

RSpec.describe InteruptionScreenHelper do
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
      incfreq: 0,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end

  describe "display_informative_text" do
    context "when 2 out of 2 arguments are given" do
      it "returns correct informative text" do
        informative_text = {
          "translation" => "soft_validations.net_income.hint_text",
          "argument" => { "ecstat1": "question", "earnings": "question" },
        }
        expect(display_informative_text(informative_text, case_log))
          .to eq("<p>You told us the main tenant’s working situation is: <strong>Full-time – 30 hours or more</strong></p><p>The household income you have entered is <strong>£750.00 every week</strong></p>")
      end
    end

    context "when 1 out of 1 arguments is given" do
      it "returns correct informative text" do
        informative_text = {
          "translation" => "test.one_argument",
          "argument" => { "ecstat1": "question" },
        }
        expect(display_informative_text(informative_text, case_log))
          .to eq("This is based on the tenant’s work situation: Full-time – 30 hours or more")
      end
    end
  end

  context "when 2 out of 1 arguments are given" do
    it "returns correct informative text" do
      informative_text = {
        "translation" => "test.one_argument",
        "argument" => { "ecstat1": "question", "earnings": "question" },
      }
      expect(display_informative_text(informative_text, case_log))
        .to eq("This is based on the tenant’s work situation: Full-time – 30 hours or more")
    end
  end

  context "when 1 out of 2 arguments are given" do
    it "returns an empty string" do
      informative_text = {
        "translation" => "soft_validations.net_income.hint_text",
        "argument" => { "ecstat1": "question" },
      }
      expect(display_informative_text(informative_text, case_log))
        .to eq("")
    end
  end
end
