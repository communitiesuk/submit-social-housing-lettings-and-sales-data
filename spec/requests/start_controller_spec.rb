require "rails_helper"

RSpec.describe StartController, type: :request do
  include CollectionTimeHelper

  let(:user) { create(:user) }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
  end

  describe "GET" do
    context "when the user is not signed in" do
      it "routes user to the start page" do
        get root_path
        expect(path).to eq("/")
        expect(page).to have_content("Start now")
      end
    end

    context "when the user is signed in" do
      before do
        allow(user).to receive(:need_two_factor_authentication?).and_return(false)
        sign_in user
      end

      it "routes user to the home page" do
        get root_path
        expect(page).to have_content("Welcome back")
      end

      describe "the data displayed at the top of the home page" do
        let(:current_year) { FormHandler.instance.current_collection_start_year }
        let(:in_crossover_period) { false }

        before do
          allow(FormHandler.instance).to receive(:in_crossover_period?).and_return in_crossover_period
        end

        context "when in the crossover period" do
          let(:in_crossover_period) { true }

          it "shows both open collection years with last year first" do
            get root_path

            logs_headers = page.find_all("h2").map(&:text).select { |header| header.include? "Logs" }

            expected_headers = [
              "#{current_year - 1} to #{current_year} Logs",
              "#{current_year} to #{current_year + 1} Logs",
            ]

            expect(logs_headers).to eq expected_headers
          end
        end

        context "when not in the crossover period" do
          let(:in_crossover_period) { false }

          it "shows this year first, with last year's after marked as closed" do
            get root_path

            logs_headers = page.find_all("h2").map(&:text).select { |header| header.include? "Logs" }

            expected_headers = [
              "#{current_year} to #{current_year + 1} Logs",
              "#{current_year - 1} to #{current_year} Logs (Closed collection year)",
            ]

            expect(logs_headers).to eq expected_headers
          end
        end

        context "when the user's org has never submitted sales" do
          it "does not display data related to sales" do
            get root_path

            databox_texts = page.find_all(".app-data-box__upper").map(&:text)
            any_sales_boxes = databox_texts.map(&:downcase).any? { |text| text.include? "sales" }

            expect(any_sales_boxes).to be false
          end
        end

        context "when the user's org has submitted sales logs" do
          before do
            create(:sales_log, assigned_to: user)
          end

          it "displays data related to sales" do
            get root_path

            databox_texts = page.find_all(".app-data-box__upper").map(&:text)
            any_sales_boxes = databox_texts.map(&:downcase).any? { |text| text.include? "sales" }

            expect(any_sales_boxes).to be true
          end
        end

        context "when the user is a data provider" do
          let(:user) { create(:user, :data_provider) }

          it "does not display data related to schemes" do
            get root_path

            databox_texts = page.find_all(".app-data-box__upper").map(&:text)
            any_schemes_boxes = databox_texts.map(&:downcase).any? { |text| text.include? "schemes" }

            expect(any_schemes_boxes).to be false
          end
        end

        context "when the user is a data coordinator" do
          let(:user) { create(:user, :data_coordinator) }

          it "does display data related to schemes" do
            get root_path

            databox_texts = page.find_all(".app-data-box__upper").map(&:text)
            any_schemes_boxes = databox_texts.map(&:downcase).any? { |text| text.include? "schemes" }

            expect(any_schemes_boxes).to be true
          end
        end

        context "when the user is a support user" do
          let(:user) { create(:user, :support) }

          it "does display data related to schemes" do
            get root_path

            databox_texts = page.find_all(".app-data-box__upper").map(&:text)
            any_schemes_boxes = databox_texts.map(&:downcase).any? { |text| text.include? "schemes" }

            expect(any_schemes_boxes).to be true
          end
        end

        describe "the links in the data boxes" do
          let(:user) { create(:user, :data_coordinator) }
          let(:in_crossover_period) { true }

          before do
            create(:sales_log, assigned_to: user)
            get root_path
          end

          [
            { type: "lettings", status: "in_progress" },
            { type: "lettings", status: "completed" },
            { type: "sales", status: "in_progress" },
            { type: "sales", status: "completed" },
          ].each do |test_case|
            it "shows the correct links for #{test_case[:status]} #{test_case[:type]}" do
              databoxes = all_databoxes(test_case[:type], test_case[:status])

              expect(databoxes.count).to be 2

              links = databoxes.map { |databox| link_from_databox databox }

              expect(links.map(&:path)).to all eq send("#{test_case[:type]}_logs_path")

              params = links.map { |link| CGI.parse(link.query) }

              expect(params.map { |prms| prms["status[]"] }).to all eq [test_case[:status]]
              expect(params.first["years[]"]).to eq [(current_year - 1).to_s]
              expect(params.second["years[]"]).to eq [current_year.to_s]
            end
          end

          it "shows the correct links for incomplete schemes" do
            type = "schemes"
            status = "incomplete"
            databoxes = all_databoxes(type, status)

            expect(databoxes.count).to be 1

            link = databoxes.map { |databox| link_from_databox databox }.first

            expect(link.path).to eq schemes_path

            params = CGI.parse(link.query)

            expect(params["status[]"]).to eq [status]
          end
        end

        describe "the counts displayed" do
          let(:in_crossover_period) { true }
          let(:org_1) { create(:organisation) }
          let(:org_2) { create(:organisation) }
          let(:provider_1) { create(:user, :data_provider, organisation: org_1) }
          let(:provider_2) { create(:user, :data_provider, organisation: org_2) }
          let(:coordinator) { create(:user, :data_coordinator, organisation: org_1) }
          let(:support_user) { create(:user, :support) }

          context "and logged in as a provider" do
            let(:user) { provider_1 }

            it "shows the correct counts of logs created by them" do
              last_year_in_progress_count = 2
              this_year_in_progress_count = 3
              create_list(:lettings_log, last_year_in_progress_count, :in_progress, :ignore_validation_errors, assigned_to: provider_1, startdate: Time.zone.today - 1.year)
              create_list(:lettings_log, this_year_in_progress_count, :in_progress, assigned_to: provider_1, startdate: Time.zone.today)

              get root_path

              type = "lettings"
              status = "in_progress"
              databoxes = all_databoxes(type, status)
              counts = databoxes.map { |databox| count_from_databox databox }

              expect(counts).to eq [last_year_in_progress_count, this_year_in_progress_count]
            end

            it "does not include logs created by other users in the count, whether in their organisation or not" do
              create(:lettings_log, :in_progress, :ignore_validation_errors, assigned_to: coordinator, startdate: Time.zone.today - 1.year)
              create(:lettings_log, :in_progress, assigned_to: provider_2, startdate: Time.zone.today)

              get root_path

              type = "lettings"
              status = "in_progress"
              databoxes = all_databoxes(type, status)
              counts = databoxes.map { |databox| count_from_databox databox }

              expect(counts).to eq [0, 0]
            end
          end

          context "and logged in as a coordinator" do
            let(:user) { coordinator }

            it "shows the correct counts of logs created by all users in their organisation" do
              last_year_in_progress_count = 2
              this_year_in_progress_count = 3
              create_list(:lettings_log, last_year_in_progress_count, :in_progress, :ignore_validation_errors, assigned_to: provider_1, startdate: Time.zone.today - 1.year)
              create_list(:lettings_log, this_year_in_progress_count, :in_progress, assigned_to: coordinator, startdate: Time.zone.today)

              get root_path

              type = "lettings"
              status = "in_progress"
              databoxes = all_databoxes(type, status)
              counts = databoxes.map { |databox| count_from_databox databox }

              expect(counts).to eq [last_year_in_progress_count, this_year_in_progress_count]
            end

            it "does not include logs created by users from other organisations in the count" do
              create(:lettings_log, :in_progress, assigned_to: provider_2, startdate: Time.zone.today)

              get root_path

              type = "lettings"
              status = "in_progress"
              databoxes = all_databoxes(type, status)

              counts = databoxes.map { |databox| count_from_databox databox }
              expect(counts).to eq [0, 0]
            end

            it "shows the correct count for schemes" do
              completed_schemes_count = 3
              incomplete_schemes_count = 2
              create_list(:scheme, completed_schemes_count, :incomplete, owning_organisation: coordinator.organisation)
              create_list(:scheme, incomplete_schemes_count, :incomplete, owning_organisation: coordinator.organisation, discarded_at: Time.zone.yesterday)

              get root_path

              type = "schemes"
              status = "incomplete"
              databoxes = all_databoxes(type, status)
              count = count_from_databox(databoxes.first)

              expect(count).to eq(completed_schemes_count)
            end
          end

          context "and logged in as a support user" do
            let(:user) { support_user }

            it "shows the correct counts of all logs from all orgs" do
              provider_1_lettings_last_year_in_progress_count = 2
              coordinator_lettings_this_year_in_progress_count = 3
              provider_2_lettings_last_year_in_progress_count = 2
              provider_2_sales_this_year_in_progress_count = 3
              create_list(:lettings_log, provider_1_lettings_last_year_in_progress_count, :in_progress, :ignore_validation_errors, assigned_to: provider_1, startdate: Time.zone.today - 1.year)
              create_list(:lettings_log, coordinator_lettings_this_year_in_progress_count, :in_progress, assigned_to: coordinator, startdate: Time.zone.today)
              create_list(:lettings_log, provider_2_lettings_last_year_in_progress_count, :in_progress, :ignore_validation_errors, assigned_to: provider_2, startdate: Time.zone.today - 1.year)
              create_list(:sales_log, provider_2_sales_this_year_in_progress_count, :in_progress, assigned_to: provider_2, saledate: Time.zone.today)

              get root_path

              type = "lettings"
              status = "in_progress"
              lettings_databoxes = all_databoxes(type, status)
              lettings_counts = lettings_databoxes.map { |databox| count_from_databox databox }

              expect(lettings_counts).to eq [
                provider_1_lettings_last_year_in_progress_count + provider_2_lettings_last_year_in_progress_count,
                coordinator_lettings_this_year_in_progress_count,
              ]

              type = "sales"
              status = "in_progress"
              sales_databoxes = all_databoxes(type, status)
              sales_counts = sales_databoxes.map { |databox| count_from_databox databox }

              expect(sales_counts).to eq [
                0,
                provider_2_sales_this_year_in_progress_count,
              ]
            end
          end
        end
      end

      context "and previous collection window is open for editing" do
        before do
          create(:collection_resource, :additional, year: previous_collection_start_year, log_type: "sales", display_name: "sales additional resource (#{previous_collection_start_year} to #{previous_collection_end_year})")
          Timecop.freeze(current_collection_start_date)
        end

        after do
          Timecop.return
        end

        it "displays correct resources for previous and current collection years" do
          current_collection_start_year_short = current_collection_start_year - 2000
          current_collection_end_year_short = current_collection_end_year - 2000
          previous_collection_start_year_short = previous_collection_start_year - 2000
          previous_collection_end_year_short = previous_collection_end_year - 2000
          current_collection_range_slash = "#{current_collection_start_year_short}/#{current_collection_end_year_short}"
          previous_collection_range_slash = "#{previous_collection_start_year_short}/#{previous_collection_end_year_short}"
          current_collection_range_to = "#{current_collection_start_year} to #{current_collection_end_year}"
          previous_collection_range_to = "#{previous_collection_start_year} to #{previous_collection_end_year}"

          get root_path
          expect(page).to have_content("Lettings #{current_collection_range_slash}")
          expect(page).to have_content("Lettings #{previous_collection_range_slash}")
          expect(page).to have_content("Lettings #{current_collection_range_to}")
          expect(page).to have_content("Lettings #{previous_collection_range_to}")
          expect(page).to have_content("Sales #{current_collection_range_slash}")
          expect(page).to have_content("Sales #{previous_collection_range_slash}")
          expect(page).to have_content("Sales #{current_collection_range_to}")
          expect(page).to have_content("Sales #{previous_collection_range_to}")
          expect(page).to have_content("Download the sales additional resource (#{previous_collection_range_to})")
        end
      end

      context "and previous collection window is closed for editing" do
        before do
          Timecop.freeze(current_collection_start_date + 6.months)
        end

        after do
          Timecop.return
        end

        it "displays correct resources for current collection year only" do
          current_collection_start_year_short = current_collection_start_year - 2000
          current_collection_end_year_short = current_collection_end_year - 2000
          previous_collection_start_year_short = previous_collection_start_year - 2000
          previous_collection_end_year_short = previous_collection_end_year - 2000
          current_collection_range_slash = "#{current_collection_start_year_short}/#{current_collection_end_year_short}"
          previous_collection_range_slash = "#{previous_collection_start_year_short}/#{previous_collection_end_year_short}"
          current_collection_range_to = "#{current_collection_start_year} to #{current_collection_end_year}"
          previous_collection_range_to = "#{previous_collection_start_year} to #{previous_collection_end_year}"

          get root_path
          expect(page).to have_content("Lettings #{current_collection_range_slash}")
          expect(page).not_to have_content("Lettings #{previous_collection_range_slash}")
          expect(page).to have_content("Lettings #{current_collection_range_to}")
          expect(page).not_to have_content("Lettings #{previous_collection_range_to}")
          expect(page).to have_content("Sales #{current_collection_range_slash}")
          expect(page).not_to have_content("Sales #{previous_collection_range_slash}")
          expect(page).to have_content("Sales #{current_collection_range_to}")
          expect(page).not_to have_content("Sales #{previous_collection_range_to}")
        end
      end

      it "shows guidance link" do
        get root_path
        expect(page).to have_content("Guidance for submitting social housing lettings and sales data (CORE)")
      end

      it "displays About this service section" do
        get root_path
        expect(page).to have_content("About this service")
      end

      context "with support user" do
        let(:user) { create(:user, :support) }

        it "displays link to edit collection resources" do
          get root_path

          expect(page).to have_link("Manage collection resources", href: collection_resources_path)
        end
      end

      context "with data coordinator" do
        it "does not display the link to edit collection resources" do
          get root_path

          expect(page).not_to have_link("Manage collection resources", href: collection_resources_path)
        end
      end
    end
  end

  describe "guidance page" do
    context "when the user is not signed in" do
      it "routes user to the guidance page" do
        get guidance_path
        expect(page).to have_content("Guidance for submitting social housing lettings and sales data")
      end
    end

    context "when the user is signed in" do
      before do
        sign_in user
      end

      it "routes user to the guidance page" do
        get guidance_path
        expect(page).to have_content("Guidance for submitting social housing lettings and sales data")
      end
    end
  end

private

  def all_databoxes(type, status)
    databoxes = page.find_all(".app-data-box__upper")
    databoxes.select do |box|
      box.text.downcase.include?(type) &&
        box.text.downcase.include?(status.humanize.downcase)
    end
  end

  def link_from_databox(databox)
    URI.parse(databox.first("a")[:href])
  end

  def count_from_databox(databox)
    databox.first("a").text.to_i
  end
end
