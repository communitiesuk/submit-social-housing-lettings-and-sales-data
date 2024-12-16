require "rails_helper"

RSpec.describe "DeleteLogs", type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user, name: "Richard MacDuff") }

  before do
    allow(user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in user
  end

  describe "GET lettings-logs/delete-logs" do
    let!(:log_1) { create(:lettings_log, :in_progress, assigned_to: user) }
    let!(:log_2) { create(:lettings_log, :completed, assigned_to: user) }

    before do
      allow(FilterManager).to receive(:filter_logs).and_return LettingsLog.all
    end

    it "calls the filter service with the filters in the session and the search term from the query params" do
      search = "Schrödinger's cat"
      logs_filters = {
        "status" => %w[in_progress],
        "assigned_to" => "all",
      }
      get lettings_logs_path(logs_filters) # adds the filters to the session

      expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
        expect(arg1).to contain_exactly(log_1, log_2)
        expect(arg2).to eq search
        expect(arg3).to eq logs_filters
      }.and_return LettingsLog.all

      get delete_logs_lettings_logs_path(search:)
    end

    it "displays the logs returned by the filter service" do
      get delete_logs_lettings_logs_path

      table_body_rows = page.find_all("tbody tr")
      expect(table_body_rows.count).to be 2
      ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
      expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
    end

    it "checks all checkboxes by default" do
      get delete_logs_lettings_logs_path

      checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
      expect(checkboxes.count).to be 2
      expect(checkboxes).to all be_checked
    end
  end

  describe "POST lettings-logs/delete-logs" do
    let!(:log_1) { create(:lettings_log, :in_progress, assigned_to: user) }
    let!(:log_2) { create(:lettings_log, :completed, assigned_to: user) }
    let(:selected_ids) { log_1.id }

    before do
      allow(FilterManager).to receive(:filter_logs).and_return LettingsLog.all
    end

    it "returns bad request if selected ids are not provided" do
      post delete_logs_lettings_logs_path
      expect(response).to have_http_status(:bad_request)
    end

    it "calls the filter service with the filters in the session and the search term from the query params" do
      search = "Schrödinger's cat"
      logs_filters = {
        "status" => %w[in_progress],
        "assigned_to" => "all",
      }
      get lettings_logs_path(logs_filters) # adds the filters to the session

      expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
        expect(arg1).to contain_exactly(log_1, log_2)
        expect(arg2).to eq search
        expect(arg3).to eq logs_filters
      }.and_return LettingsLog.all

      post delete_logs_lettings_logs_path(search:, selected_ids:)
    end

    it "displays the logs returned by the filter service" do
      post delete_logs_lettings_logs_path(selected_ids:)

      table_body_rows = page.find_all("tbody tr")
      expect(table_body_rows.count).to be 2
      ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
      expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
    end

    it "only checks the selected checkboxes when selected_ids provided" do
      post delete_logs_lettings_logs_path(selected_ids:)

      checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
      checkbox_expected_checked = checkboxes.find { |cb| cb.value == log_1.id.to_s }
      checkbox_expected_unchecked = checkboxes.find { |cb| cb.value == log_2.id.to_s }
      expect(checkbox_expected_checked).to be_checked
      expect(checkbox_expected_unchecked).not_to be_checked
    end
  end

  describe "POST lettings-logs/delete-logs-confirmation" do
    let(:log_1) { create(:lettings_log, :in_progress) }
    let(:log_2) { create(:lettings_log, :completed) }
    let(:log_3) { create(:lettings_log, :in_progress) }
    let(:params) do
      {
        forms_delete_logs_form: {
          search_term: "milk",
          selected_ids: [log_1, log_2].map(&:id),
        },
      }
    end

    before do
      post delete_logs_confirmation_lettings_logs_path, params:
    end

    it "requires delete logs form data to be provided" do
      post delete_logs_confirmation_lettings_logs_path
      expect(response).to have_http_status(:bad_request)
    end

    it "shows the correct title" do
      expect(page.find("h1").text).to include "Are you sure you want to delete these logs?"
    end

    it "shows the correct information text to the user" do
      expect(page).to have_selector("p", text: "You've selected 2 logs to delete")
    end

    context "when only one log is selected" do
      let(:params) do
        {
          forms_delete_logs_form: {
            search_term: "milk",
            selected_ids: [log_1].map(&:id),
          },
        }
      end

      it "shows the correct information text to the user in the singular" do
        expect(page).to have_selector("p", text: "You've selected 1 log to delete")
      end
    end

    it "shows a warning to the user" do
      expect(page).to have_selector(".govuk-warning-text", text: "You will not be able to undo this action")
    end

    it "shows a button to delete the selected logs" do
      expect(page).to have_selector("form.button_to button", text: "Delete logs")
    end

    it "the delete logs button submits the correct data to the correct path" do
      form_containing_button = page.find("form.button_to")

      expect(form_containing_button[:action]).to eq delete_logs_lettings_logs_path
      expect(form_containing_button).to have_field "_method", type: :hidden, with: "delete"
      expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_1.id
      expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_2.id
    end

    it "shows a cancel button with the correct style" do
      expect(page).to have_selector("button.govuk-button--secondary", text: "Cancel")
    end

    it "the cancel button submits the correct data to the correct path" do
      form_containing_cancel = page.find_all("form").find { |form| form.has_selector?("button.govuk-button--secondary") }
      expect(form_containing_cancel).to have_field("selected_ids", type: :hidden, with: [log_1, log_2].map(&:id).join(" "))
      expect(form_containing_cancel).to have_field("search", type: :hidden, with: "milk")
      expect(form_containing_cancel[:method]).to eq "post"
      expect(form_containing_cancel[:action]).to eq delete_logs_lettings_logs_path
    end

    context "when no logs are selected" do
      let(:params) do
        {
          forms_delete_logs_form: {
            log_type: :lettings,
            log_ids: [log_1, log_2, log_3].map(&:id).join(" "),
          },
        }
      end

      before do
        post delete_logs_confirmation_lettings_logs_path, params:
      end

      it "renders the list of logs table again" do
        expect(page.find("h1").text).to include "Review the logs you want to delete"
      end

      it "displays an error message" do
        expect(page).to have_selector(".govuk-error-summary", text: "Select at least one log to delete or press cancel to return")
      end

      it "renders the table with all checkboxes unchecked" do
        checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
        checkboxes.each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end
    end
  end

  describe "DELETE lettings-logs/delete-logs" do
    let(:log_1) { create(:lettings_log, :in_progress, assigned_to: user) }
    let(:params) { { ids: [log_1.id, log_2.id] } }

    context "when the user is authorized to delete the logs provided" do
      let(:log_2) { create(:lettings_log, :completed, assigned_to: user) }

      it "deletes the logs provided" do
        delete delete_logs_lettings_logs_path, params: params
        log_1.reload
        expect(log_1.status).to eq "deleted"
        expect(log_1.discarded_at).not_to be nil
        log_2.reload
        expect(log_2.status).to eq "deleted"
        expect(log_2.discarded_at).not_to be nil
      end

      it "redirects to the lettings log index and displays a notice that the logs have been deleted" do
        delete delete_logs_lettings_logs_path, params: params
        expect(response).to redirect_to lettings_logs_path
        follow_redirect!
        expect(page).to have_selector(".govuk-notification-banner--success")
        expect(page).to have_selector(".govuk-notification-banner--success", text: "2 logs have been deleted.")
      end
    end

    context "when the user is not authorized to delete all the logs provided" do
      let(:log_2) { create(:lettings_log, :completed) }

      it "returns unauthorised and only deletes logs for which the user is authorised" do
        delete delete_logs_lettings_logs_path, params: params
        expect(response).to have_http_status(:unauthorized)
        log_1.reload
        expect(log_1.status).to eq "deleted"
        expect(log_1.discarded_at).not_to be nil
        log_2.reload
        expect(log_2.discarded_at).to be nil
      end
    end

    context "when an authorized user deletes a log that had duplicates" do
      context "and only 1 log remains in the duplicate set" do
        let!(:log_1) { create(:lettings_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_2) { create(:lettings_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_3) { create(:lettings_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }

        it "deletes the log and marks related logs deduplicated" do
          delete delete_logs_lettings_logs_path, params: params
          log_1.reload
          expect(log_1.status).to eq "deleted"
          expect(log_1.discarded_at).not_to be nil
          expect(log_1.duplicates.count).to eq(0)
          expect(log_1.duplicate_set_id).to be nil
          log_2.reload
          expect(log_2.status).to eq "deleted"
          expect(log_2.discarded_at).not_to be nil
          expect(log_2.duplicates.count).to eq(0)
          expect(log_2.duplicate_set_id).to be nil
          log_3.reload
          expect(log_3.duplicates.count).to eq(0)
          expect(log_3.duplicate_set_id).to be nil
        end
      end

      context "and multiple logs remains in the duplicate set" do
        let!(:log_1) { create(:lettings_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_2) { create(:lettings_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_3) { create(:lettings_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let(:params) { { ids: [log_1.id] } }

        it "deletes the log and marks related logs deduplicated" do
          delete delete_logs_lettings_logs_path, params: params
          log_1.reload
          expect(log_1.status).to eq "deleted"
          expect(log_1.discarded_at).not_to be nil
          expect(log_1.duplicates.count).to eq(0)
          expect(log_1.duplicate_set_id).to be nil
          log_2.reload
          log_3.reload
          expect(log_2.duplicates.count).to eq(1)
          expect(log_3.duplicates.count).to eq(1)
          expect(log_3.duplicate_set_id).not_to be nil
          expect(log_3.duplicate_set_id).to eq(log_2.duplicate_set_id)
        end
      end
    end
  end

  describe "GET sales-logs/delete-logs" do
    let!(:log_1) { create(:sales_log, :in_progress, assigned_to: user) }
    let!(:log_2) { create(:sales_log, :completed, assigned_to: user) }

    before do
      allow(FilterManager).to receive(:filter_logs).and_return SalesLog.all
    end

    it "calls the filter service with the filters in the session and the search term from the query params" do
      search = "Schrödinger's cat"
      logs_filters = {
        "status" => %w[in_progress],
        "assigned_to" => "all",
      }
      get sales_logs_path(logs_filters) # adds the filters to the session

      expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
        expect(arg1).to contain_exactly(log_1, log_2)
        expect(arg2).to eq search
        expect(arg3).to eq logs_filters
      }.and_return SalesLog.all

      get delete_logs_sales_logs_path(search:)
    end

    it "displays the logs returned by the filter service" do
      get delete_logs_sales_logs_path

      table_body_rows = page.find_all("tbody tr")
      expect(table_body_rows.count).to be 2
      ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
      expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
    end

    it "checks all checkboxes by default" do
      get delete_logs_sales_logs_path

      checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
      expect(checkboxes.count).to be 2
      expect(checkboxes).to all be_checked
    end
  end

  describe "POST sales-logs/delete-logs" do
    let!(:log_1) { create(:sales_log, :in_progress, assigned_to: user) }
    let!(:log_2) { create(:sales_log, :completed, assigned_to: user) }
    let(:selected_ids) { log_1.id }

    before do
      allow(FilterManager).to receive(:filter_logs).and_return SalesLog.all
    end

    it "returns bad request if selected ids are not provided" do
      post delete_logs_sales_logs_path
      expect(response).to have_http_status(:bad_request)
    end

    it "calls the filter service with the filters in the session and the search term from the query params" do
      search = "Schrödinger's cat"
      logs_filters = {
        "status" => %w[in_progress],
        "assigned_to" => "all",
      }
      get sales_logs_path(logs_filters) # adds the filters to the session

      expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
        expect(arg1).to contain_exactly(log_1, log_2)
        expect(arg2).to eq search
        expect(arg3).to eq logs_filters
      }.and_return SalesLog.all

      post delete_logs_sales_logs_path(search:, selected_ids:)
    end

    it "displays the logs returned by the filter service" do
      post delete_logs_sales_logs_path(selected_ids:)

      table_body_rows = page.find_all("tbody tr")
      expect(table_body_rows.count).to be 2
      ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
      expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
    end

    it "only checks the selected checkboxes when selected_ids provided" do
      post delete_logs_sales_logs_path(selected_ids:)

      checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
      checkbox_expected_checked = checkboxes.find { |cb| cb.value == log_1.id.to_s }
      checkbox_expected_unchecked = checkboxes.find { |cb| cb.value == log_2.id.to_s }
      expect(checkbox_expected_checked).to be_checked
      expect(checkbox_expected_unchecked).not_to be_checked
    end
  end

  describe "POST sales-logs/delete-logs-confirmation" do
    let(:log_1) { create(:sales_log, :in_progress) }
    let(:log_2) { create(:sales_log, :completed) }
    let(:log_3) { create(:sales_log, :in_progress) }
    let(:params) do
      {
        forms_delete_logs_form: {
          search_term: "milk",
          selected_ids: [log_1, log_2].map(&:id),
        },
      }
    end

    before do
      post delete_logs_confirmation_sales_logs_path, params:
    end

    it "requires delete logs form data to be provided" do
      post delete_logs_confirmation_sales_logs_path
      expect(response).to have_http_status(:bad_request)
    end

    it "shows the correct title" do
      expect(page.find("h1").text).to include "Are you sure you want to delete these logs?"
    end

    it "shows the correct information text to the user" do
      expect(page).to have_selector("p", text: "You've selected 2 logs to delete")
    end

    context "when only one log is selected" do
      let(:params) do
        {
          forms_delete_logs_form: {
            search_term: "milk",
            selected_ids: [log_1].map(&:id),
          },
        }
      end

      it "shows the correct information text to the user in the singular" do
        expect(page).to have_selector("p", text: "You've selected 1 log to delete")
      end
    end

    it "shows a warning to the user" do
      expect(page).to have_selector(".govuk-warning-text", text: "You will not be able to undo this action")
    end

    it "shows a button to delete the selected logs" do
      expect(page).to have_selector("form.button_to button", text: "Delete logs")
    end

    it "the delete logs button submits the correct data to the correct path" do
      form_containing_button = page.find("form.button_to")

      expect(form_containing_button[:action]).to eq delete_logs_sales_logs_path
      expect(form_containing_button).to have_field "_method", type: :hidden, with: "delete"
      expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_1.id
      expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_2.id
    end

    it "shows a cancel button with the correct style" do
      expect(page).to have_selector("button.govuk-button--secondary", text: "Cancel")
    end

    it "the cancel button submits the correct data to the correct path" do
      form_containing_cancel = page.find_all("form").find { |form| form.has_selector?("button.govuk-button--secondary") }
      expect(form_containing_cancel).to have_field("selected_ids", type: :hidden, with: [log_1, log_2].map(&:id).join(" "))
      expect(form_containing_cancel).to have_field("search", type: :hidden, with: "milk")
      expect(form_containing_cancel[:method]).to eq "post"
      expect(form_containing_cancel[:action]).to eq delete_logs_sales_logs_path
    end

    context "when no logs are selected" do
      let(:params) do
        {
          forms_delete_logs_form: {
            log_type: :sales,
            log_ids: [log_1, log_2, log_3].map(&:id).join(" "),
          },
        }
      end

      before do
        post delete_logs_confirmation_sales_logs_path, params:
      end

      it "renders the list of logs table again" do
        expect(page.find("h1").text).to include "Review the logs you want to delete"
      end

      it "displays an error message" do
        expect(page).to have_selector(".govuk-error-summary", text: "Select at least one log to delete or press cancel to return")
      end

      it "renders the table with all checkboxes unchecked" do
        checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
        checkboxes.each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end
    end
  end

  describe "DELETE sales-logs/delete-logs" do
    let(:log_1) { create(:sales_log, :in_progress, assigned_to: user) }
    let(:params) { { ids: [log_1.id, log_2.id] } }

    context "when the user is authorized to delete the logs provided" do
      let(:log_2) { create(:sales_log, :completed, assigned_to: user) }

      it "deletes the logs provided" do
        delete delete_logs_sales_logs_path, params: params
        log_1.reload
        expect(log_1.status).to eq "deleted"
        expect(log_1.discarded_at).not_to be nil
        log_2.reload
        expect(log_2.status).to eq "deleted"
        expect(log_2.discarded_at).not_to be nil
      end

      it "redirects to the sales log index and displays a notice that the logs have been deleted" do
        delete delete_logs_sales_logs_path, params: params
        expect(response).to redirect_to sales_logs_path
        follow_redirect!
        expect(page).to have_selector(".govuk-notification-banner--success")
        expect(page).to have_selector(".govuk-notification-banner--success", text: "2 logs have been deleted.")
      end
    end

    context "when the user is not authorized to delete all the logs provided" do
      let(:log_2) { create(:sales_log, :completed) }

      it "returns unauthorised and only deletes logs for which the user is authorised" do
        delete delete_logs_sales_logs_path, params: params
        expect(response).to have_http_status(:unauthorized)
        log_1.reload
        expect(log_1.status).to eq "deleted"
        expect(log_1.discarded_at).not_to be nil
        log_2.reload
        expect(log_2.discarded_at).to be nil
      end
    end

    context "when an authorized user deletes a log that had duplicates" do
      context "and only 1 log remains in the duplicate set" do
        let!(:log_1) { create(:sales_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_2) { create(:sales_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_3) { create(:sales_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }

        it "deletes the log and marks related logs deduplicated" do
          delete delete_logs_sales_logs_path, params: params
          log_1.reload
          expect(log_1.status).to eq "deleted"
          expect(log_1.discarded_at).not_to be nil
          expect(log_1.duplicates.count).to eq(0)
          expect(log_1.duplicate_set_id).to be nil
          log_2.reload
          expect(log_2.status).to eq "deleted"
          expect(log_2.discarded_at).not_to be nil
          expect(log_2.duplicates.count).to eq(0)
          expect(log_2.duplicate_set_id).to be nil
          log_3.reload
          expect(log_3.duplicates.count).to eq(0)
          expect(log_3.duplicate_set_id).to be nil
        end
      end

      context "and multiple logs remains in the duplicate set" do
        let!(:log_1) { create(:sales_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_2) { create(:sales_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let!(:log_3) { create(:sales_log, :duplicate, duplicate_set_id: 5, assigned_to: user) }
        let(:params) { { ids: [log_1.id] } }

        it "deletes the log and marks related logs deduplicated" do
          delete delete_logs_sales_logs_path, params: params
          log_1.reload
          expect(log_1.status).to eq "deleted"
          expect(log_1.discarded_at).not_to be nil
          expect(log_1.duplicates.count).to eq(0)
          expect(log_1.duplicate_set_id).to be nil
          log_2.reload
          log_3.reload
          expect(log_2.duplicates.count).to eq(1)
          expect(log_3.duplicates.count).to eq(1)
          expect(log_3.duplicate_set_id).not_to be nil
          expect(log_3.duplicate_set_id).to eq(log_2.duplicate_set_id)
        end
      end
    end
  end

  context "when a support user navigates to the organisations tab" do
    let(:organisation) { create(:organisation, name: "Schmorganisation") }
    let(:user) { create(:user, :support, name: "Urban Chronotis") }

    describe "GET organisations/delete-lettings-logs" do
      let!(:log_1) { create(:lettings_log, :in_progress, owning_organisation: organisation) }
      let!(:log_2) { create(:lettings_log, :completed, owning_organisation: organisation) }

      before do
        allow(FilterManager).to receive(:filter_logs).and_return LettingsLog.all
      end

      it "calls the filter service with the filters in the session and the search term from the query params" do
        search = "Schrödinger's cat"
        logs_filters = {
          "status" => %w[in_progress],
          "assigned_to" => "all",
        }
        get lettings_logs_path(logs_filters) # adds the filters to the session

        expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
          expect(arg1).to contain_exactly(log_1, log_2)
          expect(arg2).to eq search
          expect(arg3).to eq logs_filters.merge(organisation: organisation.id.to_s)
        }.and_return LettingsLog.all

        get delete_lettings_logs_organisation_path(id: organisation, search:)
      end

      it "displays the logs returned by the filter service" do
        get delete_lettings_logs_organisation_path(id: organisation)

        table_body_rows = page.find_all("tbody tr")
        expect(table_body_rows.count).to be 2
        ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
        expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
      end

      it "checks all checkboxes by default" do
        get delete_lettings_logs_organisation_path(id: organisation)

        checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
        expect(checkboxes.count).to be 2
        expect(checkboxes).to all be_checked
      end
    end

    describe "POST organisations/delete-lettings-logs" do
      let!(:log_1) { create(:lettings_log, :in_progress, owning_organisation: organisation) }
      let!(:log_2) { create(:lettings_log, :completed, owning_organisation: organisation) }
      let(:selected_ids) { log_1.id }

      before do
        allow(FilterManager).to receive(:filter_logs).and_return LettingsLog.all
      end

      it "returns bad request if selected ids are not provided" do
        post delete_lettings_logs_organisation_path(id: organisation)
        expect(response).to have_http_status(:bad_request)
      end

      it "calls the filter service with the filters in the session and the search term from the query params" do
        search = "Schrödinger's cat"
        logs_filters = {
          "status" => %w[in_progress],
          "assigned_to" => "all",
        }
        get lettings_logs_path(logs_filters) # adds the filters to the session

        expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
          expect(arg1).to contain_exactly(log_1, log_2)
          expect(arg2).to eq search
          expect(arg3).to eq logs_filters.merge(organisation: organisation.id.to_s)
        }.and_return LettingsLog.all

        post delete_lettings_logs_organisation_path(id: organisation, search:, selected_ids:)
      end

      it "displays the logs returned by the filter service" do
        post delete_lettings_logs_organisation_path(id: organisation, selected_ids:)

        table_body_rows = page.find_all("tbody tr")
        expect(table_body_rows.count).to be 2
        ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
        expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
      end

      it "only checks the selected checkboxes when selected_ids provided" do
        post delete_lettings_logs_organisation_path(id: organisation, selected_ids:)

        checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
        checkbox_expected_checked = checkboxes.find { |cb| cb.value == log_1.id.to_s }
        checkbox_expected_unchecked = checkboxes.find { |cb| cb.value == log_2.id.to_s }
        expect(checkbox_expected_checked).to be_checked
        expect(checkbox_expected_unchecked).not_to be_checked
      end
    end

    describe "POST organisations/delete-lettings-logs-confirmation" do
      let(:log_1) { create(:lettings_log, :in_progress, owning_organisation: organisation) }
      let(:log_2) { create(:lettings_log, :completed, owning_organisation: organisation) }
      let(:log_3) { create(:lettings_log, :in_progress, owning_organisation: organisation) }
      let(:params) do
        {
          forms_delete_logs_form: {
            search_term: "milk",
            selected_ids: [log_1, log_2].map(&:id),
          },
        }
      end

      before do
        post delete_lettings_logs_confirmation_organisation_path(id: organisation), params:
      end

      it "requires delete logs form data to be provided" do
        post delete_lettings_logs_confirmation_organisation_path(id: organisation)
        expect(response).to have_http_status(:bad_request)
      end

      it "shows the correct title" do
        expect(page.find("h1").text).to include "Are you sure you want to delete these logs?"
      end

      it "shows the correct information text to the user" do
        expect(page).to have_selector("p", text: "You've selected 2 logs to delete")
      end

      context "when only one log is selected" do
        let(:params) do
          {
            forms_delete_logs_form: {
              search_term: "milk",
              selected_ids: [log_1].map(&:id),
            },
          }
        end

        it "shows the correct information text to the user in the singular" do
          expect(page).to have_selector("p", text: "You've selected 1 log to delete")
        end
      end

      it "shows a warning to the user" do
        expect(page).to have_selector(".govuk-warning-text", text: "You will not be able to undo this action")
      end

      it "shows a button to delete the selected logs" do
        expect(page).to have_selector("form.button_to button", text: "Delete logs")
      end

      it "the delete logs button submits the correct data to the correct path" do
        form_containing_button = page.find("form.button_to")

        expect(form_containing_button[:action]).to eq delete_lettings_logs_organisation_path(id: organisation)
        expect(form_containing_button).to have_field "_method", type: :hidden, with: "delete"
        expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_1.id
        expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_2.id
      end

      it "shows a cancel button with the correct style" do
        expect(page).to have_selector("button.govuk-button--secondary", text: "Cancel")
      end

      it "the cancel button submits the correct data to the correct path" do
        form_containing_cancel = page.find_all("form").find { |form| form.has_selector?("button.govuk-button--secondary") }
        expect(form_containing_cancel).to have_field("selected_ids", type: :hidden, with: [log_1, log_2].map(&:id).join(" "))
        expect(form_containing_cancel).to have_field("search", type: :hidden, with: "milk")
        expect(form_containing_cancel[:method]).to eq "post"
        expect(form_containing_cancel[:action]).to eq delete_lettings_logs_organisation_path(id: organisation)
      end

      context "when no logs are selected" do
        let(:params) do
          {
            forms_delete_logs_form: {
              log_type: :lettings,
              log_ids: [log_1, log_2, log_3].map(&:id).join(" "),
            },
          }
        end

        before do
          post delete_lettings_logs_confirmation_organisation_path(id: organisation, params:)
        end

        it "renders the list of logs table again" do
          expect(page.find("h1").text).to include "Review the logs you want to delete"
        end

        it "displays an error message" do
          expect(page).to have_selector(".govuk-error-summary", text: "Select at least one log to delete or press cancel to return")
        end

        it "renders the table with all checkboxes unchecked" do
          checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
          checkboxes.each do |checkbox|
            expect(checkbox).not_to be_checked
          end
        end
      end
    end

    describe "DELETE organisations/delete-lettings-logs" do
      let(:log_1) { create(:lettings_log, :in_progress, owning_organisation: organisation) }
      let(:log_2) { create(:lettings_log, :completed, owning_organisation: organisation) }
      let(:params) { { ids: [log_1.id, log_2.id] } }

      before do
        delete delete_lettings_logs_organisation_path(id: organisation, params:)
      end

      it "deletes the logs provided" do
        log_1.reload
        expect(log_1.status).to eq "deleted"
        expect(log_1.discarded_at).not_to be nil
        log_2.reload
        expect(log_2.status).to eq "deleted"
        expect(log_2.discarded_at).not_to be nil
      end

      it "redirects to the lettings log index for that organisation and displays a notice that the logs have been deleted" do
        expect(response).to redirect_to lettings_logs_organisation_path(id: organisation)
        follow_redirect!
        expect(page).to have_selector(".govuk-notification-banner--success")
        expect(page).to have_selector(".govuk-notification-banner--success", text: "2 logs have been deleted.")
      end
    end

    describe "GET organisations/delete-sales-logs" do
      let!(:log_1) { create(:sales_log, :in_progress, owning_organisation: organisation) }
      let!(:log_2) { create(:sales_log, :completed, owning_organisation: organisation) }

      before do
        allow(FilterManager).to receive(:filter_logs).and_return SalesLog.all
      end

      it "calls the filter service with the filters in the session and the search term from the query params" do
        search = "Schrödinger's cat"
        logs_filters = {
          "status" => %w[in_progress],
          "assigned_to" => "all",
        }
        get sales_logs_path(logs_filters) # adds the filters to the session

        expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
          expect(arg1).to contain_exactly(log_1, log_2)
          expect(arg2).to eq search
          expect(arg3).to eq logs_filters.merge(organisation: organisation.id.to_s)
        }.and_return SalesLog.all

        get delete_sales_logs_organisation_path(id: organisation, search:)
      end

      it "displays the logs returned by the filter service" do
        get delete_sales_logs_organisation_path(id: organisation)

        table_body_rows = page.find_all("tbody tr")
        expect(table_body_rows.count).to be 2
        ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
        expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
      end

      it "checks all checkboxes by default" do
        get delete_sales_logs_organisation_path(id: organisation)

        checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
        expect(checkboxes.count).to be 2
        expect(checkboxes).to all be_checked
      end
    end

    describe "POST organisations/delete-sales-logs" do
      let!(:log_1) { create(:sales_log, :in_progress, owning_organisation: organisation) }
      let!(:log_2) { create(:sales_log, :completed, owning_organisation: organisation) }
      let(:selected_ids) { log_1.id }

      before do
        allow(FilterManager).to receive(:filter_logs).and_return SalesLog.all
      end

      it "returns bad request if selected ids are not provided" do
        post delete_sales_logs_organisation_path(id: organisation)
        expect(response).to have_http_status(:bad_request)
      end

      it "calls the filter service with the filters in the session and the search term from the query params" do
        search = "Schrödinger's cat"
        logs_filters = {
          "status" => %w[in_progress],
          "assigned_to" => "all",
        }
        get sales_logs_path(logs_filters) # adds the filters to the session

        expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3|
          expect(arg1).to contain_exactly(log_1, log_2)
          expect(arg2).to eq search
          expect(arg3).to eq logs_filters.merge(organisation: organisation.id.to_s)
        }.and_return SalesLog.all

        post delete_sales_logs_organisation_path(id: organisation, search:, selected_ids:)
      end

      it "displays the logs returned by the filter service" do
        post delete_sales_logs_organisation_path(id: organisation, selected_ids:)

        table_body_rows = page.find_all("tbody tr")
        expect(table_body_rows.count).to be 2
        ids_in_table = table_body_rows.map { |row| row.first("td").text.strip }
        expect(ids_in_table).to match_array [log_1.id.to_s, log_2.id.to_s]
      end

      it "only checks the selected checkboxes when selected_ids provided" do
        post delete_sales_logs_organisation_path(id: organisation, selected_ids:)

        checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
        checkbox_expected_checked = checkboxes.find { |cb| cb.value == log_1.id.to_s }
        checkbox_expected_unchecked = checkboxes.find { |cb| cb.value == log_2.id.to_s }
        expect(checkbox_expected_checked).to be_checked
        expect(checkbox_expected_unchecked).not_to be_checked
      end
    end

    describe "POST organisations/delete-sales-logs-confirmation" do
      let(:log_1) { create(:sales_log, :in_progress, owning_organisation: organisation) }
      let(:log_2) { create(:sales_log, :completed, owning_organisation: organisation) }
      let(:log_3) { create(:sales_log, :in_progress, owning_organisation: organisation) }
      let(:params) do
        {
          forms_delete_logs_form: {
            search_term: "milk",
            selected_ids: [log_1, log_2].map(&:id),
          },
        }
      end

      before do
        post delete_sales_logs_confirmation_organisation_path(id: organisation), params:
      end

      it "requires delete logs form data to be provided" do
        post delete_sales_logs_confirmation_organisation_path
        expect(response).to have_http_status(:bad_request)
      end

      it "shows the correct title" do
        expect(page.find("h1").text).to include "Are you sure you want to delete these logs?"
      end

      it "shows the correct information text to the user" do
        expect(page).to have_selector("p", text: "You've selected 2 logs to delete")
      end

      context "when only one log is selected" do
        let(:params) do
          {
            forms_delete_logs_form: {
              search_term: "milk",
              selected_ids: [log_1].map(&:id),
            },
          }
        end

        it "shows the correct information text to the user in the singular" do
          expect(page).to have_selector("p", text: "You've selected 1 log to delete")
        end
      end

      it "shows a warning to the user" do
        expect(page).to have_selector(".govuk-warning-text", text: "You will not be able to undo this action")
      end

      it "shows a button to delete the selected logs" do
        expect(page).to have_selector("form.button_to button", text: "Delete logs")
      end

      it "the delete logs button submits the correct data to the correct path" do
        form_containing_button = page.find("form.button_to")

        expect(form_containing_button[:action]).to eq delete_sales_logs_organisation_path(id: organisation)
        expect(form_containing_button).to have_field "_method", type: :hidden, with: "delete"
        expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_1.id
        expect(form_containing_button).to have_field "ids[]", type: :hidden, with: log_2.id
      end

      it "shows a cancel button with the correct style" do
        expect(page).to have_selector("button.govuk-button--secondary", text: "Cancel")
      end

      it "the cancel button submits the correct data to the correct path" do
        form_containing_cancel = page.find_all("form").find { |form| form.has_selector?("button.govuk-button--secondary") }
        expect(form_containing_cancel).to have_field("selected_ids", type: :hidden, with: [log_1, log_2].map(&:id).join(" "))
        expect(form_containing_cancel).to have_field("search", type: :hidden, with: "milk")
        expect(form_containing_cancel[:method]).to eq "post"
        expect(form_containing_cancel[:action]).to eq delete_sales_logs_organisation_path(id: organisation)
      end

      context "when no logs are selected" do
        let(:params) do
          {
            forms_delete_logs_form: {
              log_type: :sales,
              log_ids: [log_1, log_2, log_3].map(&:id).join(" "),
            },
          }
        end

        before do
          post delete_sales_logs_confirmation_organisation_path(id: organisation, params:)
        end

        it "renders the list of logs table again" do
          expect(page.find("h1").text).to include "Review the logs you want to delete"
        end

        it "displays an error message" do
          expect(page).to have_selector(".govuk-error-summary", text: "Select at least one log to delete or press cancel to return")
        end

        it "renders the table with all checkboxes unchecked" do
          checkboxes = page.find_all("tbody tr").map { |row| row.find("input") }
          checkboxes.each do |checkbox|
            expect(checkbox).not_to be_checked
          end
        end
      end
    end

    describe "DELETE organisations/delete-sales-logs" do
      let(:log_1) { create(:sales_log, :in_progress, owning_organisation: organisation) }
      let(:log_2) { create(:sales_log, :completed, owning_organisation: organisation) }
      let(:params) { { ids: [log_1.id, log_2.id] } }

      before do
        delete delete_sales_logs_organisation_path(id: organisation, params:)
      end

      it "deletes the logs provided" do
        log_1.reload
        expect(log_1.status).to eq "deleted"
        expect(log_1.discarded_at).not_to be nil
        log_2.reload
        expect(log_2.status).to eq "deleted"
        expect(log_2.discarded_at).not_to be nil
      end

      it "redirects to the sales log index for that organisation and displays a notice that the logs have been deleted" do
        expect(response).to redirect_to sales_logs_organisation_path(id: organisation)
        follow_redirect!
        expect(page).to have_selector(".govuk-notification-banner--success")
        expect(page).to have_selector(".govuk-notification-banner--success", text: "2 logs have been deleted.")
      end
    end
  end
end
