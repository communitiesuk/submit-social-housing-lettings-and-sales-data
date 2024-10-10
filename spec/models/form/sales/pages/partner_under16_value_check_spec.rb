require "rails_helper"

RSpec.describe Form::Sales::Pages::PartnerUnder16ValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 1 }

  let(:page_id) { "partner_under_16_value_check" }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "is interruption screen page" do
    expect(page.interruption_screen?).to eq(true)
  end

  context "with person 1" do
    let(:person_index) { 1 }
    let(:page_id) { "partner_under_16_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[partner_under_16_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("partner_under_16_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_1_partner_under_16?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.partner_under_16_sales.title",
        "arguments" => [
          {
            "key" => "age1",
            "label" => true,
            "i18n_template" => "age",
          },
        ],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[age1 relat1])
    end
  end

  context "with person 2" do
    let(:person_index) { 2 }
    let(:page_id) { "person_2_partner_under_16_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[partner_under_16_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_partner_under_16_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_2_partner_under_16?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.partner_under_16_sales.title",
        "arguments" => [
          {
            "key" => "age2",
            "label" => true,
            "i18n_template" => "age",
          },
        ],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[age2 relat2])
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }
    let(:page_id) { "person_3_partner_under_16_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[partner_under_16_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_partner_under_16_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_3_partner_under_16?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.partner_under_16_sales.title",
        "arguments" => [
          {
            "key" => "age3",
            "label" => true,
            "i18n_template" => "age",
          },
        ],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[age3 relat3])
    end
  end

  context "with person 4" do
    let(:person_index) { 4 }
    let(:page_id) { "person_4_partner_under_16_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[partner_under_16_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_4_partner_under_16_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_4_partner_under_16?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.partner_under_16_sales.title",
        "arguments" => [
          {
            "key" => "age4",
            "label" => true,
            "i18n_template" => "age",
          },
        ],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[age4 relat4])
    end
  end

  context "with person 5" do
    let(:person_index) { 5 }
    let(:page_id) { "person_5_partner_under_16_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[partner_under_16_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_5_partner_under_16_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_5_partner_under_16?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.partner_under_16_sales.title",
        "arguments" => [
          {
            "key" => "age5",
            "label" => true,
            "i18n_template" => "age",
          },
        ],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[age5 relat5])
    end
  end

  context "with person 6" do
    let(:person_index) { 6 }
    let(:page_id) { "person_6_partner_under_16_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[partner_under_16_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_6_partner_under_16_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "person_6_partner_under_16?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.partner_under_16_sales.title",
        "arguments" => [
          {
            "key" => "age6",
            "label" => true,
            "i18n_template" => "age",
          },
        ],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[age6 relat6])
    end
  end
end
