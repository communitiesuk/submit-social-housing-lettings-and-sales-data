require "rails_helper"

RSpec.describe Form::Sales::Pages::HandoverDateCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "" }
  let(:page_definition) { nil }

  context "when form start year is <= 2024" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }
    let(:subsection) { instance_double(Form::Subsection, form:) }

    it "has correct subsection" do
      expect(page.subsection).to eq(subsection)
    end

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[hodate_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("handover_date_check")
    end

    it "has the correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "forms.2024.sales.soft_validations.hodate_check.title_text",
        "arguments" => [],
      })
    end

    it "has the correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([
        { "hodate_3_years_or_more_saledate?" => true, "saledate_check" => nil },
        { "hodate_3_years_or_more_saledate?" => true, "saledate_check" => 1 },
      ])
    end

    it "is interruption screen page" do
      expect(page.interruption_screen?).to eq(true)
    end

    it "is has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[hodate saledate])
    end
  end

  context "when form start year is 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1), start_year_2025_or_later?: true) }
    let(:subsection) { instance_double(Form::Subsection, form:) }

    it "has the correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "forms.2025.sales.soft_validations.hodate_check.title_text",
        "arguments" => [],
      })
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([
        { "hodate_5_years_or_more_saledate?" => true, "saledate_check" => nil },
        { "hodate_5_years_or_more_saledate?" => true, "saledate_check" => 1 },
      ])
    end
  end
end
