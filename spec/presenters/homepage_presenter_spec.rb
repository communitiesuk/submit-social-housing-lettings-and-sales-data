require "rails_helper"

RSpec.describe HomepagePresenter do
  let(:organisation) { create(:organisation) }
  let(:user) { create(:user, organisation:) }
  let(:in_crossover_period) { true }
  let(:presenter) { described_class.new(user) }
  let(:date_this_year) { FormHandler.instance.current_collection_start_date }
  let(:date_last_year) { FormHandler.instance.previous_collection_start_date }
  let(:expected_count) { rand 1..10 }

  before do
    allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(in_crossover_period)
  end

  context "when the user is support" do
    let(:user) { create(:user, :support) }

    it "sets the correct title" do
      expect(presenter.title_text_for_user).to eq "Manage all data"
    end

    it "returns that schemes should be displayed" do
      expect(presenter.display_schemes?).to be true
    end

    it "returns that sales logs should be displayed" do
      expect(presenter.display_sales?).to be true
    end
  end

  context "when the user is a data coordinator" do
    let(:user) { create(:user, :data_coordinator) }

    it "sets the correct title" do
      expect(presenter.title_text_for_user).to eq "Manage your organisation's logs"
    end

    it "returns that schemes should be displayed" do
      expect(presenter.display_schemes?).to be true
    end
  end

  context "when the user is a data provider" do
    let(:user) { create(:user, :data_provider) }

    it "sets the correct title" do
      expect(presenter.title_text_for_user).to eq "Manage logs assigned to you"
    end

    it "returns that schemes should not be displayed" do
      expect(presenter.display_schemes?).to be false
    end
  end

  context "when the user's organisation has never submitted sales logs" do
    it "shows the user's organisation does not log sales" do
      expect(presenter.display_sales?).to be false
    end

    context "when in the crossover period" do
      let(:in_crossover_period) { true }

      it "leaves all sales related data as nil" do
        sales_data = [
          presenter.current_year_in_progress_sales_data,
          presenter.current_year_completed_sales_data,
          presenter.last_year_in_progress_sales_data,
          presenter.last_year_completed_sales_data,
        ]
        expect(sales_data).to all be nil
      end
    end

    context "when not in the crossover period" do
      let(:in_crossover_period) { false }

      it "leaves all sales related data as nil" do
        sales_data = [
          presenter.current_year_in_progress_sales_data,
          presenter.current_year_completed_sales_data,
          presenter.last_year_in_progress_sales_data,
          presenter.last_year_completed_sales_data,
        ]
        expect(sales_data).to all be nil
      end
    end
  end

  context "when the user's organisation has submitted sales logs" do
    before do
      create(:sales_log, assigned_to: user)
    end

    it "shows the user's organisation logs sales" do
      expect(presenter.display_sales?).to be true
    end

    context "when in the crossover period" do
      let(:in_crossover_period) { true }

      it "populates all sales related data" do
        sales_data = [
          presenter.current_year_in_progress_sales_data,
          presenter.current_year_completed_sales_data,
          presenter.last_year_in_progress_sales_data,
          presenter.last_year_completed_sales_data,
        ]
        expect(sales_data).to all be_an_instance_of(Hash)
      end
    end

    context "when not in the crossover period" do
      let(:in_crossover_period) { false }

      it "populates all relevant sales related data" do
        sales_data = [
          presenter.current_year_in_progress_sales_data,
          presenter.current_year_completed_sales_data,
          presenter.last_year_completed_sales_data,
        ]
        expect(sales_data).to all be_an_instance_of(Hash)
      end

      it "does not populate data for last year's in progress logs" do
        last_year_in_progress_data = [
          presenter.last_year_in_progress_lettings_data,
          presenter.last_year_in_progress_sales_data,
        ]
        expect(last_year_in_progress_data).to all be nil
      end
    end
  end

  context "when in the crossover period" do
    let(:in_crossover_period) { true }

    it "returns that we are in the crossover period" do
      expect(presenter.in_crossover_period?).to be true
    end
  end

  context "when not in the crossover period" do
    let(:in_crossover_period) { false }

    it "returns that we are in the crossover period" do
      expect(presenter.in_crossover_period?).to be false
    end
  end

  describe "the data collected and exposed by the presenter" do
    context "with lettings logs" do
      let(:type) { :lettings_log }

      context "with in progress status" do
        let(:status) { :in_progress }

        context "and the current year" do
          let(:startdate) { date_this_year }

          it "exposes the correct data for the data box" do
            create_list(type, expected_count, status, assigned_to: user, startdate:)
            data = presenter.current_year_in_progress_lettings_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Lettings in progress"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_this_year.year.to_s]
          end
        end

        context "and the last year" do
          let(:startdate) { date_last_year }

          it "exposes the correct data for the data box" do
            logs = build_list(type, expected_count, status, assigned_to: user, startdate:)
            logs.each { |log| log.save(validate: false) }
            data = presenter.last_year_in_progress_lettings_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Lettings in progress"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_last_year.year.to_s]
          end
        end
      end

      context "with completed status" do
        let(:status) { :completed }

        context "and the current year" do
          let(:startdate) { date_this_year }

          it "exposes the correct data for the data box" do
            create_list(type, expected_count, :completed, assigned_to: user, startdate:)
            data = presenter.current_year_completed_lettings_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Completed lettings"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_this_year.year.to_s]
          end
        end

        context "and the last year" do
          let(:startdate) { date_last_year }

          it "exposes the correct data for the data box" do
            logs = build_list(type, expected_count, status, assigned_to: user, startdate:)
            logs.each { |log| log.save(validate: false) }
            data = presenter.last_year_completed_lettings_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Completed lettings"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_last_year.year.to_s]
          end
        end
      end
    end

    context "with sales logs" do
      let(:type) { :sales_log }

      context "with in progress status" do
        let(:status) { :in_progress }

        context "and the current year" do
          let(:saledate) { date_this_year }

          it "exposes the correct data for the data box" do
            create_list(type, expected_count, status, assigned_to: user, saledate:)
            data = presenter.current_year_in_progress_sales_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Sales in progress"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_this_year.year.to_s]
          end
        end

        context "and the last year" do
          let(:saledate) { date_last_year }

          it "exposes the correct data for the data box" do
            logs = build_list(type, expected_count, status, assigned_to: user, saledate:)
            logs.each { |log| log.save(validate: false) }
            data = presenter.last_year_in_progress_sales_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Sales in progress"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_last_year.year.to_s]
          end
        end
      end

      context "with completed status" do
        let(:status) { :completed }

        context "and the current year" do
          let(:saledate) { date_this_year }

          it "exposes the correct data for the data box" do
            create_list(type, expected_count, :completed, assigned_to: user, saledate:)
            data = presenter.current_year_completed_sales_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Completed sales"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_this_year.year.to_s]
          end
        end

        context "and the last year" do
          let(:saledate) { date_last_year }

          it "exposes the correct data for the data box" do
            logs = build_list(type, expected_count, status, assigned_to: user, saledate:)
            logs.each { |log| log.save(validate: false) }
            data = presenter.last_year_completed_sales_data

            expect(data[:count]).to be expected_count
            expect(data[:text]).to eq "Completed sales"
            uri = URI.parse(data[:path])
            expect(uri.path).to eq "/#{type.to_s.dasherize}s"
            query_params = CGI.parse(uri.query)
            expect(query_params["status[]"]).to eq [status.to_s]
            expect(query_params["years[]"]).to eq [date_last_year.year.to_s]
          end
        end
      end
    end
  end
end
