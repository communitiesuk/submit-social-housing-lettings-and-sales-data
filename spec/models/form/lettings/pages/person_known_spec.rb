require "rails_helper"

RSpec.describe Form::Lettings::Pages::PersonKnown, type: :model do
  subject(:page) { described_class.new(nil, page_definition, subsection, person_index:) }

  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:person_index) { 2 }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has the correct header" do
    expect(page.header).to eq("You’ve given us the details for 1 person in the household")
  end

  it "has the correct description" do
    expect(page.description).to eq("")
  end

  context "with person 2" do
    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[details_known_2])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_2_known")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "hhmemb" => 2 },
         { "hhmemb" => 3 },
         { "hhmemb" => 4 },
         { "hhmemb" => 5 },
         { "hhmemb" => 6 },
         { "hhmemb" => 7 },
         { "hhmemb" => 8 }],
      )
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[details_known_3])
    end

    it "has the correct id" do
      expect(page.id).to eq("person_3_known")
    end

    it "has correct depends_on" do
      expect(page.depends_on).to eq(
        [{ "hhmemb" => 3 },
         { "hhmemb" => 4 },
         { "hhmemb" => 5 },
         { "hhmemb" => 6 },
         { "hhmemb" => 7 },
         { "hhmemb" => 8 }],
      )
    end
  end
end
