require "rails_helper"

RSpec.describe "logs/delete_logs.html.erb" do
  let(:user) { create(:user, :support, name: "Dirk Gently") }
  let(:lettings_log_1) { create(:lettings_log, tenancycode: "Holistic", propcode: "Detective Agency", assigned_to: user) }
  let(:lettings_logs) { [lettings_log_1] }
  let(:paths) do
    {
      delete_confirmation_path: delete_logs_confirmation_lettings_logs_path,
      back_to_logs_path: lettings_logs_path(search: "search_term"),
      delete_path: delete_logs_lettings_logs_path,
    }
  end
  let(:delete_logs_form) { Forms::DeleteLogsForm.new(log_type: :lettings, current_user: user, **paths) }

  before do
    sign_in user
    allow(FilterManager).to receive(:filter_logs).and_return lettings_logs
    assign(:delete_logs_form, delete_logs_form)
  end

  it "has the correct h1 content" do
    render
    fragment = Capybara::Node::Simple.new(rendered)
    h1 = fragment.find("h1")
    expect(h1.text).to include "Review the logs you want to delete"
  end

  context "when there is one log to delete" do
    it "shows the informative text in the singular" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      info_text = fragment.first("p").text
      expect(info_text).to eq "You've selected 1 log to delete"
    end
  end

  context "when there is more than one log to delete" do
    let(:lettings_log_2) { create(:lettings_log, tenancycode: "01-354", propcode: "9112") }

    before do
      lettings_logs << lettings_log_2
      allow(FilterManager).to receive(:filter_logs).and_return lettings_logs
      delete_logs_form = Forms::DeleteLogsForm.new(log_type: :lettings, current_user: user, **paths)
      assign(:delete_logs_form, delete_logs_form)
    end

    it "shows the informative text in the plural" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      info_text = fragment.first("p").text
      expect(info_text).to eq "You've selected #{lettings_logs.count} logs to delete"
    end
  end

  context "when the table contains lettings logs" do
    it "shows the correct headers in the table" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      headers = fragment.find_all("table thead tr th").map(&:text)
      expect(headers).to eq ["Log ID", "Tenancy code", "Property reference", "Status", "Delete?"]
    end

    it "shows the correct information in each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      row_data = fragment.find_all("table tbody tr td").map(&:text)[0...-1].map(&:strip)
      expect(row_data).to eq [lettings_log_1.id.to_s, lettings_log_1.tenancycode, lettings_log_1.propcode, lettings_log_1.status.humanize.capitalize]
    end

    it "links to the relevant log on each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      first_cell = fragment.first("table tbody tr td")
      expect(first_cell).to have_link lettings_log_1.id.to_s, href: lettings_log_path(lettings_log_1)
    end
  end

  context "when the table contains sales logs" do
    let(:sales_log) { create(:sales_log, purchid: "Interconnectedness", saledate: Time.zone.today, assigned_to: user) }
    let(:sales_logs) { [sales_log] }
    let(:delete_logs_form_sales) { Forms::DeleteLogsForm.new(log_type: :sales, current_user: user, **paths) }

    before do
      sign_in user
      allow(FilterManager).to receive(:filter_logs).and_return sales_logs
      assign(:delete_logs_form, delete_logs_form_sales)
    end

    it "shows the correct headers in the table" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      headers = fragment.find_all("table thead tr th").map(&:text)
      expect(headers).to eq ["Log ID", "Purchaser code", "Sale completion date", "Status", "Delete?"]
    end

    it "shows the correct information in each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      row_data = fragment.find_all("table tbody tr td").map(&:text)[0...-1].map(&:strip)
      expect(row_data).to eq [sales_log.id.to_s, sales_log.purchid, sales_log.saledate.to_formatted_s(:govuk_date), sales_log.status.humanize.capitalize]
    end

    it "links to the relevant log on each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      first_cell = fragment.first("table tbody tr td")
      expect(first_cell).to have_link sales_log.id.to_s, href: sales_log_path(sales_log)
    end
  end

  it "shows a checkbox with the correct hidden label in the final cell of each row" do
    render
    fragment = Capybara::Node::Simple.new(rendered)
    final_cell = fragment.find_all("table tbody tr td")[-1]
    expect(final_cell.find("input")[:type]).to eq "checkbox"
    checkbox_label = final_cell.find("label span")
    expect(checkbox_label.text).to eq lettings_log_1.id.to_s
    expect(checkbox_label[:class]).to include "govuk-visually-hidden"
  end
end
