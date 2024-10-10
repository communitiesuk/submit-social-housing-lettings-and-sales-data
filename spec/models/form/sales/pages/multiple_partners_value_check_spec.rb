require "rails_helper"

RSpec.describe Form::Sales::Pages::MultiplePartnersValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 1 }

  let(:page_id) { "multiple_partners_value_check" }

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
    let(:page_id) { "multiple_partners_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[multiple_partners_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("multiple_partners_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "multiple_partners?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.multiple_partners_sales.title",
        "arguments" => [],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat2 relat3 relat4 relat5 relat6])
    end
  end

  context "with person 2" do
    let(:person_index) { 2 }
    let(:page_id) { "person_2_multiple_partners_value_check" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[multiple_partners_value_check])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_multiple_partners_value_check")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "multiple_partners?" => true }])
    end

    it "has correct title_text" do
      expect(page.title_text).to eq({
        "translation" => "soft_validations.multiple_partners_sales.title",
        "arguments" => [],
      })
    end

    it "has correct informative_text" do
      expect(page.informative_text).to eq({})
    end

    it "has correct interruption_screen_question_ids" do
      expect(page.interruption_screen_question_ids).to eq(%w[relat2 relat3 relat4 relat5 relat6])
    end
  end
end
