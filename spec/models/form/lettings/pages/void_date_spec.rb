require "rails_helper"

RSpec.describe Form::Lettings::Pages::VoidDate, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[voiddate])
  end

  it "has the correct id" do
    expect(page.id).to eq("void_date")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([{ "is_renewal?" => false, "vacancy_reason_not_renewal_or_first_let?" => true }, { "has_first_let_vacancy_reason?" => true, "is_renewal?" => false }])
  end
end
