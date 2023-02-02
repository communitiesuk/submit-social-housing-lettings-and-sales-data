require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonGenderIdentity, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 2 }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to be nil
  end

  it "has the correct description" do
    expect(page.description).to be nil
  end

  context "with person 2" do
    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sex2])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_gender_identity")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "details_known_2" => 0 }],
      )
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[sex3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_gender_identity")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "details_known_3" => 0 }],
      )
    end
  end
end
