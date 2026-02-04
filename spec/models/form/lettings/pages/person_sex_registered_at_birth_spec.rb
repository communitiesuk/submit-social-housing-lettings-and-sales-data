require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonSexRegisteredAtBirth, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2026, 4, 1))) }
  let(:person_index) { 1 }

  let(:page_id) { "person_2_sex_registered_at_birth" }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  context "with person 2" do
    let(:person_index) { 2 }
    let(:page_id) { "person_2_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab2])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_2" => 1 }])
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }
    let(:page_id) { "person_3_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_3" => 1 }])
    end
  end

  context "with person 4" do
    let(:person_index) { 4 }
    let(:page_id) { "person_4_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab4])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_4_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_4" => 1 }])
    end
  end

  context "with person 5" do
    let(:person_index) { 5 }
    let(:page_id) { "person_5_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab5])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_5_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_5" => 1 }])
    end
  end

  context "with person 6" do
    let(:person_index) { 6 }
    let(:page_id) { "person_6_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab6])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_6_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_6" => 1 }])
    end
  end

  context "with person 7" do
    let(:person_index) { 7 }
    let(:page_id) { "person_7_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab7])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_7_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_7" => 1 }])
    end
  end

  context "with person 8" do
    let(:person_index) { 8 }
    let(:page_id) { "person_8_sex_registered_at_birth" }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sexrab8])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_8_sex_registered_at_birth")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq([{ "details_known_8" => 1 }])
    end
  end
end
