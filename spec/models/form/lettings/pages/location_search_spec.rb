require "rails_helper"

RSpec.describe Form::Lettings::Pages::LocationSearch, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has the correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "needstype" => 2,
        "scheme_has_multiple_locations?" => true,
        "scheme_has_large_number_of_locations?" => true,
      },
    ])
  end
end
