require "rails_helper"

RSpec.describe TasklistHelper do
  let(:now) { Time.utc(2022, 1, 1) }

  around do |example|
    Timecop.freeze(now) do
      Singleton.__init__(FormHandler)
      example.run
    end
    Timecop.return
  end

  describe "with lettings" do
    let(:empty_lettings_log) { create(:lettings_log) }
    let(:lettings_log) { build(:lettings_log, :in_progress, needstype: 1, startdate: now) }

    describe "get next incomplete section" do
      it "returns the first subsection name if it is not completed" do
        expect(get_next_incomplete_section(lettings_log).id).to eq("household_characteristics")
      end

      it "returns the first subsection name if it is partially completed" do
        lettings_log["tenancycode"] = 123
        expect(get_next_incomplete_section(lettings_log).id).to eq("household_characteristics")
      end
    end

    describe "get sections count" do
      let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

      before do
        allow(FormHandler.instance).to receive(:get_form).and_return(fake_2021_2022_form)
      end

      it "returns the total of sections if no status is given" do
        expect(get_subsections_count(empty_lettings_log)).to eq(8)
      end

      it "returns 0 sections for completed sections if no sections are completed" do
        expect(get_subsections_count(empty_lettings_log, :completed)).to eq(0)
      end

      it "returns the number of not started sections" do
        expect(get_subsections_count(empty_lettings_log, :not_started)).to eq(8)
      end

      it "returns the number of sections in progress" do
        expect(get_subsections_count(lettings_log, :in_progress)).to eq(2)
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

  describe "#review_log_text" do
    context "with sales log" do
      context "when collection_period_open? == true" do
        let(:now) { Time.utc(2022, 6, 1) }
        let(:sales_log) { create(:sales_log, :completed, saledate: now) }

        it "returns relevant text" do
          expect(review_log_text(sales_log)).to eq(
            "You can #{govuk_link_to 'review and make changes to this log', review_sales_log_path(id: sales_log, sales_log: true)} until 7 June 2023.".html_safe,
          )
        end
      end

      context "when collection_period_open? == false" do
        let(:now) { Time.utc(2022, 6, 1) }
        let!(:sales_log) { create(:sales_log, :completed, saledate: now) }

        it "returns relevant text" do
          Timecop.freeze(now + 1.year) do
            expect(review_log_text(sales_log)).to eq("This log is from the 2021/2022 collection window, which is now closed.")
          end
        end
      end
    end

    context "with lettings log" do
      context "when collection_period_open? == true" do
        context "with 2023 deadline" do
          let(:now) { Time.utc(2022, 6, 1) }
          let(:lettings_log) { create(:lettings_log, :completed) }

          it "returns relevant text" do
            expect(review_log_text(lettings_log)).to eq(
              "You can #{govuk_link_to 'review and make changes to this log', review_lettings_log_path(lettings_log)} until 1 July 2023.".html_safe,
            )
          end
        end

        context "with 2024 deadline" do
          let(:now) { Time.utc(2023, 6, 20) }
          let(:lettings_log) { create(:lettings_log, :completed, national: 18, waityear: 2) }

          it "returns relevant text" do
            expect(review_log_text(lettings_log)).to eq(
              "You can #{govuk_link_to 'review and make changes to this log', review_lettings_log_path(lettings_log)} until 9 June 2024.".html_safe,
            )
          end
        end
      end

      context "when collection_period_open? == false" do
        let(:now) { Time.utc(2022, 6, 1) }
        let!(:sales_log) { create(:lettings_log, :completed) }

        it "returns relevant text" do
          Timecop.freeze(now + 1.year) do
            expect(review_log_text(sales_log)).to eq("This log is from the 2021/2022 collection window, which is now closed.")
          end
        end
      end
    end
  end
end
