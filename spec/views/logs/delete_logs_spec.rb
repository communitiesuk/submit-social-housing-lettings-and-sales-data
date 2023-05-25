require "rails_helper"

RSpec.describe "logs/delete_logs.html.erb" do
  let(:lettings_log_1) { create(:lettings_log, tenancycode: "Holistic", propcode: "Detective Agency") }
  let(:lettings_logs) { [lettings_log_1] }
  let(:delete_logs_form) { Forms::DeleteLogsForm.new(log_ids: lettings_logs.map(&:id), log_type: :lettings) }

  before do
    sign_in create(:user, :support, name: "Dirk Gently")
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
      delete_logs_form = Forms::DeleteLogsForm.new(log_ids: lettings_logs.map(&:id), log_type: :lettings)
      assign(:delete_logs_form, delete_logs_form)
    end

    it "shows the informative text in the plural" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      info_text = fragment.first("p").text
      expect(info_text).to eq "You've selected #{lettings_logs.count} logs to delete"
    end
  end

  context "when the user is deletings lettings logs" do
    it "shows the correct headers in the table" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      headers = fragment.find_all("table thead tr th").map(&:text)
      expect(headers).to eq ["Log ID", "Tenancy code", "Property reference", "Status", "Delete?"]
    end

    it "shows the correct information in each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      row_data = fragment.find_all("table tbody tr td").map(&:text)[0...-1]
      expect(row_data).to eq [lettings_log_1.id.to_s, lettings_log_1.tenancycode, lettings_log_1.propcode, lettings_log_1.status.humanize.capitalize]
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

  context "when the user is deletings sales logs" do
    let(:organisation) { create(:organisation, name: "awgan-eye-zay-shun") }
    let(:sales_log_1) { create(:sales_log, owning_organisation: organisation) }
    let(:sales_logs) { [sales_log_1] }
    let(:delete_logs_form) { Forms::DeleteLogsForm.new(log_ids: sales_logs.map(&:id), log_type: :sales) }

    it "shows the correct headers in the table" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      headers = fragment.find_all("table thead tr th").map(&:text)
      expect(headers).to eq ["Log ID", "Owning organisation", "Created", "Status", "Delete?"]
    end

    it "shows the correct information in each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      row_data = fragment.find_all("table tbody tr td").map(&:text)[0...-1]
      expect(row_data).to eq [sales_log_1.id.to_s, sales_log_1.owning_organisation.name, sales_log_1.created_at.to_formatted_s(:govuk_date), sales_log_1.status.humanize.capitalize]
    end

    it "shows a checkbox with the correct hidden label in the final cell of each row" do
      render
      fragment = Capybara::Node::Simple.new(rendered)
      final_cell = fragment.find_all("table tbody tr td")[-1]
      expect(final_cell.find("input")[:type]).to eq "checkbox"
      checkbox_label = final_cell.find("label span")
      expect(checkbox_label.text).to eq sales_log_1.id.to_s
      expect(checkbox_label[:class]).to include "govuk-visually-hidden"
    end
  end
end
