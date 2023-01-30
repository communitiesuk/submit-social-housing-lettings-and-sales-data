require "rails_helper"

RSpec.describe Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "old_persons_shared_ownership_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[old_persons_shared_ownership_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("old_persons_shared_ownership_value_check")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "buyers_age_for_old_persons_shared_ownership_invalid?" => true,
      },
    ])
  end

  it "has the correct title_text" do
    expect(page.title_text).to eq({
      "translation" => "soft_validations.old_persons_shared_ownership",
      "arguments" => [],
    })
  end

  it "has the correct informative_text" do
    expect(page.informative_text).to eq({})
  end
end
