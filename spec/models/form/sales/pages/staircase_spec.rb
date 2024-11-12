require "rails_helper"

RSpec.describe Form::Sales::Pages::Staircase, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  context "when start year is 2024" do
    let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)), id: "sale_information") }

    before do
      allow(subsection.form).to receive(:start_year_2025_or_later?).and_return(false)
    end

    it "has correct subsection" do
      expect(page.subsection).to eq(subsection)
    end

    it "has correct questions" do
      expect(page.questions.map(&:id)).to eq(%w[staircase])
    end

    it "has the correct id" do
      expect(page.id).to eq("staircasing")
    end

    it "has the correct description" do
      expect(page.description).to be_nil
    end
  end

  context "when start year is >= 2025" do
    let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)), id: "setup") }

    before do
      allow(subsection.form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "has correct subsection" do
      expect(page.subsection).to eq(subsection)
    end
  end

end
