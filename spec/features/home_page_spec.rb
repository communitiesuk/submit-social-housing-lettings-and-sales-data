require "rails_helper"
require_relative "form/helpers"

RSpec.describe "Home Page Features" do
  include Helpers

  context "when there are notifications" do
    let!(:user) { FactoryBot.create(:user) }

    context "when the notifications are currently active" do
      before do
        create(:notification, title: "Notification title 1")
        create(:notification, title: "Notification title 2")
        create(:notification, title: "Notification title 3")
        sign_in user
        visit(root_path)
      end

      it "shows the latest notification with count and dismiss link" do
        expect(page).to have_content("Notification 1 of 3")
        expect(page).to have_content("Notification title 3")
        expect(page).to have_link("Dismiss")
        expect(page).to have_link("Link text")
      end

      context "when the user clicks a notification link" do
        before do
          click_link("Link text")
        end

        it "takes them to the notification details page" do
          expect(page).to have_current_path(notifications_path)
          expect(page).to have_content("Notification title 3")
          expect(page).to have_content("Some html content")
          expect(page).to have_link("Back to Home")
        end

        context "when they return" do
          before do
            click_link("Back to Home")
          end

          it "the notification has not been dismissed" do
            expect(page).to have_current_path(root_path)
            expect(page).to have_content("Notification 1 of 3")
            expect(page).to have_content("Notification title 3")
            expect(page).to have_link("Dismiss")
            expect(page).to have_link("Link text")
          end
        end
      end

      context "when the user clicks a dismiss link" do
        before do
          click_link("Dismiss")
        end

        it "dismisses the notification and takes them back" do
          expect(page).to have_current_path(root_path)
          expect(page).to have_content("Notification 1 of 2")
          expect(page).to have_content("Notification title 2")
          expect(page).to have_link("Dismiss")
          expect(page).to have_link("Link text")
        end

        context "when the user dismisses the penultimate notification" do
          before do
            click_link("Dismiss")
          end

          it "no longer displays the count" do
            expect(page).to have_current_path(root_path)
            expect(page).not_to have_content("Notification 1 of")
            expect(page).to have_content("Notification title 1")
          end

          context "when the user dismisses the final notification" do
            before do
              click_link("Dismiss")
            end

            it "no longer displays any notification" do
              expect(page).to have_current_path(root_path)
              expect(page).not_to have_content("Notification")
              expect(page).not_to have_link("Dismiss")
              expect(page).not_to have_link("Link_text")
            end
          end
        end
      end

      context "when another user has dismissed all their notifications" do
        before do
          other_user = create(:user)
          Notification.mark_as_read! :all, for: other_user
          visit(root_path)
        end

        it "the first user can still see the notifications" do
          expect(page).to have_content("Notification 1 of 3")
          expect(page).to have_content("Notification title 3")
          expect(page).to have_link("Dismiss")
          expect(page).to have_link("Link text")
        end
      end
    end

    context "when the notifications are not currently active" do
      before do
        create(:notification, end_date: Time.zone.yesterday, title: "Notification title 1")
        create(:notification, start_date: Time.zone.tomorrow, title: "Notification title 2")
        sign_in user
        visit(root_path)
      end

      it "does not show any notifications" do
        expect(page).not_to have_content("Notification title")
        expect(page).not_to have_content("Notification 1 of")
        expect(page).not_to have_link("Dismiss")
        expect(page).not_to have_link("Link text")
      end
    end
  end

  context "when the user is a data provider" do
    let(:user) { FactoryBot.create(:user, name: "Provider") }

    before do
      Timecop.freeze(Time.zone.local(2024, 1, 1))
      Singleton.__init__(FormHandler)
      create_list(:lettings_log, 6, :in_progress, owning_organisation: user.organisation, assigned_to: user)
      create_list(:lettings_log, 2, :in_progress, owning_organisation: user.organisation)
      create_list(:lettings_log, 4, :completed, owning_organisation: user.organisation, assigned_to: user)
      create_list(:lettings_log, 2, :completed)
      create_list(:lettings_log, 2, :not_started)
      sign_in user
      visit(root_path)
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    it "displays the correct welcome text" do
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back, Provider")
      expect(page).to have_content("Complete your logs")
    end

    context "when their organisation has submitted sales logs" do
      before do
        create_list(:sales_log, 5, :in_progress, owning_organisation: user.organisation, assigned_to: user)
        create_list(:sales_log, 3, :completed, owning_organisation: user.organisation, assigned_to: user)
        create_list(:sales_log, 2, :not_started)
        visit(root_path)
      end

      context "and it is not a crossover" do
        before do
          closed_period_in_progress_log = build(:lettings_log, :in_progress, owning_organisation: user.organisation, assigned_to: user, startdate: Time.zone.local(2022, 4, 1))
          closed_period_in_progress_log.save!(validate: false)
          visit(root_path)
        end

        it "displays correct data boxes, counts and links" do
          data_boxes = page.find_all(class: "app-data-box-one-half")
          expect(data_boxes.count).to eq(2)
          expect(data_boxes[0].all("a").map(&:text)).to eq(["6", "Your lettings in progress", "View all lettings"])
          expect(data_boxes[0].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "lettings_logs")])
          expect(data_boxes[1].all("a").map(&:text)).to eq(["5", "Your sales in progress", "View all sales"])
          expect(data_boxes[1].all("a").map { |line| line["href"] }).to eq([sales_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), sales_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "sales_logs")])
        end
      end

      context "and it is a crossover" do
        before do
          Timecop.freeze(Time.zone.local(2024, 4, 1))
          Singleton.__init__(FormHandler)
          closed_period_in_progress_log = build(:lettings_log, :in_progress, owning_organisation: user.organisation, assigned_to: user, startdate: Time.zone.local(2022, 4, 1))
          closed_period_in_progress_log.save!(validate: false)
          sign_in user
          visit(root_path)
        end

        it "displays correct data boxes, counts and links" do
          data_boxes = page.find_all(class: "app-data-box-one-half")

          expect(data_boxes.count).to eq(2)
          expect(data_boxes[0].all("a").map(&:text)).to eq(["6", "Your lettings in progress", "View all lettings"])
          expect(data_boxes[0].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2024 2023], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2024 2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "lettings_logs")])
          expect(data_boxes[1].all("a").map(&:text)).to eq(["5", "Your sales in progress", "View all sales"])
          expect(data_boxes[1].all("a").map { |line| line["href"] }).to eq([sales_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2024 2023], owning_organisation_select: "all", managing_organisation_select: "all"), sales_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2024 2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "sales_logs")])
        end
      end
    end

    context "when their organisation has never submitted sales logs" do
      before do
        visit(root_path)
      end

      it "displays correct data boxes, counts and links" do
        data_boxes = page.find_all(class: "app-data-box-one-half")
        expect(data_boxes.count).to eq(2)
        expect(data_boxes[0].all("a").map(&:text)).to eq(["6", "Your lettings in progress", "View all lettings"])
        expect(data_boxes[0].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: %i[in_progress], assigned_to: "you", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "lettings_logs")])
        expect(data_boxes[1].all("a").map(&:text)).to eq(["4", "Your completed lettings", "View all schemes"])
        expect(data_boxes[1].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: [:completed], assigned_to: "you", years: [""], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: [:completed], assigned_to: "you", years: [""], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "schemes")])
      end
    end
  end

  context "when the user is a data coordinator" do
    before do
      Timecop.freeze(Time.zone.local(2024, 3, 1))
      Singleton.__init__(FormHandler)
      create_list(:lettings_log, 6, :in_progress, owning_organisation: user.organisation)
      create_list(:lettings_log, 2, :in_progress, owning_organisation: user.organisation, assigned_to: user)
      create_list(:lettings_log, 4, :completed, owning_organisation: user.organisation)
      create_list(:lettings_log, 2, :completed)
      create_list(:lettings_log, 2, :not_started)
      create_list(:scheme, 1, :incomplete, owning_organisation: user.organisation)
      sign_in user
      visit(root_path)
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    let(:user) { FactoryBot.create(:user, :data_coordinator, name: "Coordinator") }

    it "displays the correct welcome text" do
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back, Coordinator")
      expect(page).to have_content("Manage your data")
    end

    context "when their organisation has submitted sales logs" do
      before do
        create_list(:sales_log, 5, :in_progress, owning_organisation: user.organisation)
        create_list(:sales_log, 3, :completed, owning_organisation: user.organisation)
        create_list(:sales_log, 2, :not_started)
        visit(root_path)
      end

      it "displays correct data boxes, counts and links" do
        data_boxes = page.find_all(class: "app-data-box-one-third")
        expect(data_boxes.count).to eq(3)
        expect(data_boxes[0].all("a").map(&:text)).to eq(["8", "Lettings in progress", "View all lettings"])
        expect(data_boxes[0].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "lettings_logs")])
        expect(data_boxes[1].all("a").map(&:text)).to eq(["5", "Sales in progress", "View all sales"])
        expect(data_boxes[1].all("a").map { |line| line["href"] }).to eq([sales_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), sales_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "sales_logs")])
        expect(data_boxes[2].all("a").map(&:text)).to eq(["1", "Incomplete schemes", "View all schemes"])
        expect(data_boxes[2].all("a").map { |line| line["href"] }).to eq([schemes_path(status: [:incomplete], owning_organisation_select: "all"), schemes_path(status: [:incomplete], owning_organisation_select: "all"), clear_filters_path(filter_type: "schemes")])
      end
    end

    context "when their organisation has never submitted sales logs" do
      before do
        visit(root_path)
      end

      it "displays correct data boxes, counts and links" do
        data_boxes = page.find_all(class: "app-data-box-one-half")
        expect(data_boxes.count).to eq(2)
        expect(data_boxes[0].all("a").map(&:text)).to eq(["8", "Lettings in progress", "View all lettings"])
        expect(data_boxes[0].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "lettings_logs")])
        expect(data_boxes[1].all("a").map(&:text)).to eq(["1", "Incomplete schemes", "View all schemes"])
        expect(data_boxes[1].all("a").map { |line| line["href"] }).to eq([schemes_path(status: [:incomplete], owning_organisation_select: "all"), schemes_path(status: [:incomplete], owning_organisation_select: "all"), clear_filters_path(filter_type: "schemes")])
      end
    end
  end

  context "when the user is a support user" do
    let(:support_user) { FactoryBot.create(:user, :support, name: "Support") }
    let(:notify_client) { instance_double(Notifications::Client) }
    let(:confirmation_token) { "MCDH5y6Km-U7CFPgAMVS" }
    let(:devise_notify_mailer) { DeviseNotifyMailer.new }
    let(:otp) { "999111" }

    before do
      Timecop.freeze(Time.zone.local(2024, 3, 1))
      Singleton.__init__(FormHandler)
      create_list(:lettings_log, 2, :in_progress)
      create_list(:lettings_log, 1, :completed)
      create_list(:lettings_log, 2, :not_started)
      create_list(:sales_log, 3, :in_progress)
      create_list(:sales_log, 1, :completed)
      create_list(:sales_log, 2, :not_started)
      create_list(:scheme, 1, :incomplete)
      completed_scheme = create(:scheme)
      create(:location, scheme: completed_scheme)
      allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
      allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
      allow(Devise).to receive(:friendly_token).and_return(confirmation_token)
      allow(notify_client).to receive(:send_email).and_return(true)
      allow(SecureRandom).to receive(:random_number).and_return(otp)
      visit("/lettings-logs")
      fill_in("user[email]", with: support_user.email)
      fill_in("user[password]", with: support_user.password)
      click_button("Sign in")
      fill_in("code", with: otp)
      click_button("Submit")
      visit(root_path)
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    it "displays the correct welcome text" do
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back, Support")
      expect(page).to have_content("Manage all data")
    end

    it "displays correct data boxes, counts and links" do
      data_boxes = page.find_all(class: "app-data-box-one-third")
      expect(data_boxes.count).to eq(3)
      expect(data_boxes[0].all("a").map(&:text)).to eq(["2", "Lettings in progress", "View all lettings"])
      expect(data_boxes[0].all("a").map { |line| line["href"] }).to eq([lettings_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), lettings_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "lettings_logs")])
      expect(data_boxes[1].all("a").map(&:text)).to eq(["3", "Sales in progress", "View all sales"])
      expect(data_boxes[1].all("a").map { |line| line["href"] }).to eq([sales_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), sales_logs_path(status: %i[in_progress], assigned_to: "all", years: %w[2023], owning_organisation_select: "all", managing_organisation_select: "all"), clear_filters_path(filter_type: "sales_logs")])
      expect(data_boxes[2].all("a").map(&:text)).to eq(["1", "Incomplete schemes", "View all schemes"])
      expect(data_boxes[2].all("a").map { |line| line["href"] }).to eq([schemes_path(status: [:incomplete], owning_organisation_select: "all"), schemes_path(status: [:incomplete], owning_organisation_select: "all"), clear_filters_path(filter_type: "schemes")])
    end
  end
end
