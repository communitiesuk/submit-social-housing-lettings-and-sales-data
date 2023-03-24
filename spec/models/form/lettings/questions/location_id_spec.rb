require "rails_helper"

RSpec.describe Form::Lettings::Questions::LocationId, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  before do
    allow(form).to receive(:start_date).and_return(Time.zone.local(2022, 4, 1))
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("location_id")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which location is this log for?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Location")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is marked as derived" do
    expect(question).not_to be_derived
  end

  context "when there are no locations" do
    it "the answer_options is an empty hash" do
      expect(question.answer_options).to eq({})
    end
  end

  context "when getting available locations" do
    let(:scheme) { FactoryBot.create(:scheme) }
    let!(:lettings_log) do
      FactoryBot.create(:lettings_log, owning_organisation: scheme.owning_organisation, needstype: 2)
    end

    context "when there are no locations" do
      it "the displayed_answer_options is an empty hash (the scheme should have failed validation anyway so don't validate here)" do
        lettings_log.scheme = scheme
        lettings_log.save!(validate: false)
        expect(question.displayed_answer_options(lettings_log)).to eq({})
      end
    end

    context "when selected scheme has locations" do
      before do
        Timecop.freeze(Time.utc(2022, 5, 12))
      end

      after do
        Timecop.unfreeze
      end

      context "and all the locations have a future startdate" do
        before do
          FactoryBot.create(:location, scheme:, startdate: Time.utc(2022, 5, 13))
          FactoryBot.create(:location, scheme:, startdate: Time.utc(2023, 1, 1))
          lettings_log.update!(scheme:)
        end

        it "the displayed_answer_options is an empty hash" do
          expect(question.displayed_answer_options(lettings_log)).to eq({})
        end
      end

      context "and the locations have no startdate" do
        before do
          FactoryBot.create(:location, scheme:, startdate: nil)
          FactoryBot.create(:location, scheme:, startdate: nil)
          lettings_log.update!(scheme:)
        end

        it "the displayed_answer_options shows the locations" do
          expect(question.displayed_answer_options(lettings_log).count).to eq(2)
        end
      end

      context "and the locations have a past startdate" do
        before do
          FactoryBot.create(:location, scheme:, startdate: Time.utc(2022, 4, 10))
          FactoryBot.create(:location, scheme:, startdate: Time.utc(2022, 5, 12))
          lettings_log.update!(scheme:)
        end

        it "the displayed_answer_options shows the locations" do
          expect(question.displayed_answer_options(lettings_log).count).to eq(2)
        end
      end

      context "and some locations have a past startdate" do
        before do
          FactoryBot.create(:location, scheme:, startdate: Time.utc(2022, 10, 10))
          FactoryBot.create(:location, scheme:, startdate: Time.utc(2022, 5, 12))
          lettings_log.update!(scheme:)
        end

        it "the displayed_answer_options shows only the active location" do
          expect(question.displayed_answer_options(lettings_log).count).to eq(1)
        end
      end

      context "and some locations are not confirmed" do
        before do
          FactoryBot.create(:location, scheme:, postcode: nil)
          FactoryBot.create(:location, scheme:)
          lettings_log.update!(scheme:)
        end

        it "the displayed_answer_options shows only the confirmed location" do
          expect(question.displayed_answer_options(lettings_log).count).to eq(1)
        end
      end
    end
  end

  context "with collection year on or after 2023" do
    before do
      allow(form).to receive(:start_date).and_return(Time.zone.local(2023, 4, 1))
    end

    it "has the correct header" do
      expect(question.header).to eq("Which location is this letting for?")
    end
  end
end
