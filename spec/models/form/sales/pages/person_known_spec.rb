require "rails_helper"

RSpec.describe Form::Sales::Pages::PersonKnown, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_id) { "person_2_known" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 1 }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to eq("")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  context "with person 1" do
    let(:page_id) { "person_1_known" }
    let(:person_index) { 1 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[details_known_1])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_1_known")
    end

    it "has the correct header_partial" do
      expect(page.header_partial).to eq("person_1_known_page")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [
          { "hholdcount" => 1 },
          { "hholdcount" => 2 },
          { "hholdcount" => 3 },
          { "hholdcount" => 4 },
        ],
      )
    end
  end

  context "with person 2" do
    let(:page_id) { "person_2_known" }
    let(:person_index) { 2 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[details_known_2])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_known")
    end

    it "has the correct header_partial" do
      expect(page.header_partial).to eq("person_2_known_page")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [
          { "hholdcount" => 2, "details_known_1" => 1 },
          { "hholdcount" => 3, "details_known_1" => 1 },
          { "hholdcount" => 4, "details_known_1" => 1 },
        ],
      )
    end
  end

  context "with person 3" do
    let(:page_id) { "person_3_known" }
    let(:person_index) { 3 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[details_known_3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_known")
    end

    it "has the correct header_partial" do
      expect(page.header_partial).to eq("person_3_known_page")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [
          { "hholdcount" => 3, "details_known_2" => 1 },
          { "hholdcount" => 4, "details_known_2" => 1 },
        ],
      )
    end
  end

  context "with person 4" do
    let(:page_id) { "person_4_known" }
    let(:person_index) { 4 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[details_known_4])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_4_known")
    end

    it "has the correct header_partial" do
      expect(page.header_partial).to eq("person_4_known_page")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [
          { "hholdcount" => 4, "details_known_3" => 1 },
        ],
      )
    end
  end
end
