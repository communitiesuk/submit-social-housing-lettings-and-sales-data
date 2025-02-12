require "rails_helper"

RSpec.describe TasklistHelper do
  describe "with lettings" do
    let(:empty_lettings_log) { create(:lettings_log) }
    let(:lettings_log) { build_stubbed(:lettings_log, :in_progress, needstype: 1) }

    describe "get next incomplete section" do
      it "returns the first subsection name if it is not completed" do
        expect(get_next_incomplete_section(lettings_log).id).to eq("property_information")
      end

      it "returns the first subsection name if it is partially completed" do
        lettings_log["uprn_known"] = 0
        expect(get_next_incomplete_section(lettings_log).id).to eq("property_information")
      end
    end

    describe "get sections count" do
      let(:completed_subsection) { instance_double("Subsection", status: :completed, displayed_in_tasklist?: true, applicable_questions: [{ id: "question" }]) }
      let(:incomplete_subsection) { instance_double("Subsection", status: :not_started, displayed_in_tasklist?: true, applicable_questions: []) }

      context "with an empty lettings log" do
        before do
          allow(empty_lettings_log.form).to receive(:subsections).and_return([incomplete_subsection])
        end

        it "returns the total displayed subsections count if no status is given" do
          expect(get_subsections_count(empty_lettings_log)).to eq(1)
        end

        it "returns 0 sections for completed sections if no sections are completed" do
          expect(get_subsections_count(empty_lettings_log, :completed)).to eq(0)
        end
      end

      context "with a partially complete lettings log" do
        before do
          allow(lettings_log.form).to receive(:subsections).and_return([completed_subsection, incomplete_subsection])
        end

        it "returns the total displayed subsections count if no status is given" do
          expect(get_subsections_count(lettings_log)).to eq(2)
        end

        it "returns the completed sections count" do
          expect(get_subsections_count(lettings_log, :completed)).to eq(1)
        end
      end

      it "returns 0 for invalid state" do
        expect(get_subsections_count(lettings_log, :fake)).to eq(0)
      end
    end

    describe "subsection link" do
      let(:lettings_log) { create(:lettings_log, :completed) }
      let(:subsection) { lettings_log.form.get_subsection("household_characteristics") }
      let(:user) { build(:user) }

      context "with a subsection that's enabled" do
        it "returns the subsection link url" do
          expect(subsection_link(subsection, lettings_log, user)).to match(/household-characteristics/)
        end
      end

      context "with a subsection that cannot be started yet" do
        before do
          allow(subsection).to receive(:status).with(lettings_log).and_return(:cannot_start_yet)
        end

        it "returns the label instead of a link" do
          expect(subsection_link(subsection, lettings_log, user)).to match(subsection.label)
        end
      end
    end
  end

  describe "with sales" do
    let(:empty_sales_log) { build(:sales_log, owning_organisation: nil) }
    let(:completed_sales_log) { build(:sales_log, :completed) }
    let(:completed_subsection) { instance_double("Subsection", status: :completed, displayed_in_tasklist?: true, applicable_questions: [{ id: "question" }]) }
    let(:incomplete_subsection) { instance_double("Subsection", status: :not_started, displayed_in_tasklist?: true, applicable_questions: []) }

    describe "get sections count" do
      context "with an empty sales log" do
        before do
          allow(empty_sales_log.form).to receive(:subsections).and_return([incomplete_subsection])
        end

        it "returns the total displayed subsections count if no status is given (includes all 3 sale information subsections)" do
          expect(get_subsections_count(empty_sales_log)).to eq(1)
        end

        it "returns 0 sections for completed sections if no sections are completed" do
          expect(get_subsections_count(empty_sales_log, :completed)).to eq(0)
        end
      end

      context "with a completed sales log" do
        before do
          allow(completed_sales_log.form).to receive(:subsections).and_return([completed_subsection])
        end

        it "returns the total displayed subsections count if no status is given (includes only the 1 relevant sale information subsection)" do
          expect(get_subsections_count(completed_sales_log)).to eq(1)
        end

        it "returns the completed sections count" do
          expect(get_subsections_count(completed_sales_log, :completed)).to eq(1)
        end
      end

      it "returns 0 for invalid state" do
        expect(get_subsections_count(completed_sales_log, :fake)).to eq(0)
      end
    end
  end

  describe "#review_log_text" do
    context "with sales log" do
      context "when collection_period_open? == true" do
        let(:sales_log) { build(:sales_log, :completed, saledate: Time.zone.local(2022, 6, 9), id: 123) }

        before do
          allow(sales_log.form).to receive(:submission_deadline).and_return(Time.zone.local(2023, 6, 9))
          allow(sales_log).to receive(:collection_period_open?).and_return(true)
        end

        it "returns relevant text" do
          expect(review_log_text(sales_log)).to eq(
            "You can #{govuk_link_to 'review and make changes to this log', review_sales_log_path(id: sales_log, sales_log: true)} until 9 June 2023.".html_safe,
          )
        end
      end

      context "when collection_period_open? == false" do
        let!(:sales_log) { build(:sales_log, :completed, saledate: Time.zone.local(2022, 6, 1)) }

        before do
          allow(sales_log.form).to receive(:submission_deadline).and_return(Time.zone.local(2023, 6, 9))
          allow(sales_log).to receive(:collection_period_open?).and_return(false)
        end

        it "returns relevant text" do
          expect(review_log_text(sales_log)).to eq("This log is from the 2022 to 2023 collection window, which is now closed.")
        end
      end

      context "when older_than_previous_collection_year" do
        let(:sales_log) { build(:sales_log, :completed, saledate: Time.zone.local(2022, 2, 1)) }

        before do
          allow(sales_log.form).to receive(:submission_deadline).and_return(Time.zone.local(2022, 6, 9))
          allow(sales_log).to receive(:older_than_previous_collection_year?).and_return(true)
        end

        it "returns relevant text" do
          expect(review_log_text(sales_log)).to eq("This log is from the 2021 to 2022 collection window, which is now closed.")
        end
      end
    end

    context "with lettings log" do
      context "when collection_period_open? == true" do
        let(:lettings_log) { build(:lettings_log, :completed, id: 123) }

        before do
          allow(lettings_log.form).to receive(:submission_deadline).and_return(Time.zone.local(2023, 6, 9))
          allow(lettings_log).to receive(:collection_period_open?).and_return(true)
        end

        it "returns relevant text" do
          expect(review_log_text(lettings_log)).to eq(
            "You can #{govuk_link_to 'review and make changes to this log', review_lettings_log_path(lettings_log)} until 9 June 2023.".html_safe,
          )
        end
      end

      context "when collection_period_open? == false" do
        let!(:lettings_log) { build(:lettings_log, :completed, startdate: Time.zone.local(2022, 6, 1), id: 123) }

        before do
          allow(lettings_log.form).to receive(:submission_deadline).and_return(Time.zone.local(2023, 6, 9))
          allow(lettings_log).to receive(:collection_period_open?).and_return(false)
        end

        it "returns relevant text" do
          expect(review_log_text(lettings_log)).to eq("This log is from the 2022 to 2023 collection window, which is now closed.")
        end
      end

      context "when older_than_previous_collection_year" do
        let(:lettings_log) { build(:lettings_log, :completed, startdate: Time.zone.local(2022, 2, 1)) }

        before do
          allow(lettings_log.form).to receive(:submission_deadline).and_return(Time.zone.local(2022, 6, 9))
          allow(lettings_log).to receive(:older_than_previous_collection_year?).and_return(true)
        end

        it "returns relevant text" do
          expect(review_log_text(lettings_log)).to eq("This log is from the 2021 to 2022 collection window, which is now closed.")
        end
      end
    end
  end

  describe "deadline text" do
    context "when log does not have a sale/start date" do
      let(:log) { build(:sales_log, saledate: nil) }

      it "returns nil" do
        expect(deadline_text(log)).to be_nil
      end
    end

    context "when log is completed" do
      let(:log) { build(:sales_log, :completed, status: "completed") }

      it "returns nil" do
        expect(deadline_text(log)).to be_nil
      end
    end

    context "when today is before the deadline for log with sale/start date" do
      let(:log) { build(:sales_log, saledate: Time.zone.local(2025, 6, 1)) }

      it "returns the deadline text" do
        allow(Time.zone).to receive(:now).and_return(Time.zone.local(2025, 5, 7))
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 5, 7))
        expect(deadline_text(log)).to include("Deadline: ")
      end
    end

    context "when today is after the deadline for log with sale/start date" do
      let(:log) { build(:sales_log, saledate: Time.zone.local(2025, 2, 1)) }

      it "returns the overdue text" do
        allow(Time.zone).to receive(:now).and_return(Time.zone.local(2025, 6, 7))
        allow(Time.zone).to receive(:today).and_return(Time.zone.local(2025, 6, 7))
        expect(deadline_text(log)).to include("Overdue: ")
      end
    end
  end
end
