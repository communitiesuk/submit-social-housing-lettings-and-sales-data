require "rails_helper"
require_relative "form/helpers"

RSpec.describe "Home Page Features" do
  include Helpers

  context "when the user is a data provider" do
    let(:user) { FactoryBot.create(:user, name: "Provider") }

    before do
      create_list(:lettings_log, 6, :in_progress, owning_organisation: user.organisation, created_by: user)
      create_list(:lettings_log, 2, :in_progress, owning_organisation: user.organisation)
      create_list(:lettings_log, 4, :completed, owning_organisation: user.organisation, created_by: user)
      create_list(:lettings_log, 2, :completed)
      sign_in user
      visit("/")
    end

    it "displays the correct welcome text" do
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back, Provider")
      expect(page).to have_content("Complete your logs")
    end

    context "when their organisation has submitted sales logs" do
      before do
        create_list(:sales_log, 5, :in_progress, owning_organisation: user.organisation, created_by: user)
        create_list(:sales_log, 3, :completed, owning_organisation: user.organisation, created_by: user)
        visit("/")
      end

      it "displays correct data boxes and counts" do
        data_boxes = page.find_all(class: "app-data-box-one-half")
        expect(data_boxes.count).to eq(2)
        expect(data_boxes[0].text.split("\n")).to eq(["6", "Your lettings in progress", "View all lettings"])
        expect(data_boxes[1].text.split("\n")).to eq(["5", "Your sales in progress", "View all sales"])
      end
    end

    context "when their organisation has never submitted sales logs" do
      before do
        visit("/")
      end

      it "displays correct data boxes and counts" do
        data_boxes = page.find_all(class: "app-data-box-one-half")
        expect(data_boxes.count).to eq(2)
        expect(data_boxes[0].text.split("\n")).to eq(["6", "Your lettings in progress", "View all lettings"])
        expect(data_boxes[1].text.split("\n")).to eq(["4", "Your completed lettings", "View all schemes"])
      end
    end
  end

  context "when the user is a data coordinator" do
    before do
      create_list(:lettings_log, 6, :in_progress, owning_organisation: user.organisation)
      create_list(:lettings_log, 2, :in_progress, owning_organisation: user.organisation, created_by: user)
      create_list(:lettings_log, 4, :completed, owning_organisation: user.organisation)
      create_list(:lettings_log, 2, :completed)
      create_list(:scheme, 1, :incomplete, owning_organisation: user.organisation)
      sign_in user
      visit("/")
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
        visit("/")
      end

      it "displays correct data boxes and counts" do
        data_boxes = page.find_all(class: "app-data-box-one-third")
        expect(data_boxes.count).to eq(3)
        expect(data_boxes[0].text.split("\n")).to eq(["8", "Lettings in progress", "View all lettings"])
        expect(data_boxes[1].text.split("\n")).to eq(["5", "Sales in progress", "View all sales"])
        expect(data_boxes[2].text.split("\n")).to eq(["1", "Incomplete schemes", "View all schemes"])
      end
    end

    context "when their organisation has never submitted sales logs" do
      before do
        visit("/")
      end

      it "displays correct data boxes and counts" do
        data_boxes = page.find_all(class: "app-data-box-one-half")
        expect(data_boxes.count).to eq(2)
        expect(data_boxes[0].text.split("\n")).to eq(["8", "Lettings in progress", "View all lettings"])
        expect(data_boxes[1].text.split("\n")).to eq(["1", "Incomplete schemes", "View all schemes"])
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
      create_list(:lettings_log, 2, :in_progress)
      create_list(:lettings_log, 1, :completed)
      create_list(:sales_log, 3, :in_progress)
      create_list(:sales_log, 1, :completed)
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
      visit("/")
    end

    it "displays the correct welcome text" do
      expect(page).to have_current_path("/")
      expect(page).to have_content("Welcome back, Support")
      expect(page).to have_content("Manage all data")
    end

    it "displays correct data boxes and counts" do
      data_boxes = page.find_all(class: "app-data-box-one-third")
      expect(data_boxes.count).to eq(3)
      expect(data_boxes[0].text.split("\n")).to eq(["2", "Lettings in progress", "View all lettings"])
      expect(data_boxes[1].text.split("\n")).to eq(["3", "Sales in progress", "View all sales"])
      expect(data_boxes[2].text.split("\n")).to eq(["1", "Incomplete schemes", "View all schemes"])
    end
  end
end
