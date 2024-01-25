require "rails_helper"

RSpec.describe Form::Lettings::Questions::Startertenancy, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  context "with collection year before 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has the correct hint_text" do
      expect(question.hint_text).to eq("This is also known as an ‘introductory period’.")
    end
  end

  context "with collection year >= 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct updated hint_text" do
      expect(question.hint_text).to eq("If the tenancy has an ‘introductory period’ answer ‘yes’.<br><br>
       You should submit a CORE log at the beginning of the starter tenancy or introductory period, with the best information you have at the time. You do not need to submit a log when a tenant later rolls onto the main tenancy.")
    end
  end

end
