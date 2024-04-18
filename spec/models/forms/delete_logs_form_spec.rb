require "rails_helper"

RSpec.describe Forms::DeleteLogsForm do
  let(:delete_logs_form) { described_class.new(attributes) }

  let(:attributes) do
    {
      log_type:,
      search_term:,
      current_user:,
      log_filters:,
      selected_ids:,
      delete_confirmation_path:,
      back_to_logs_path:,
      delete_path:,
    }
  end
  let(:log_type) { :lettings }
  let(:search_term) { "meaning" }
  let(:current_user) { create(:user) }
  let(:log_filters) do
    {
      "years" => [""],
      "status" => ["", "completed"],
      "user" => "you",
    }
  end
  let(:selected_ids) { [visible_logs.first.id] }
  let(:delete_confirmation_path) { "/lettings-logs/delete-logs-confirmation" }
  let(:back_to_logs_path) { "/lettings-logs?search=meaning" }
  let(:delete_path) { "/lettings-logs/delete-logs" }

  let(:visible_logs) { create_list(:lettings_log, 3, assigned_to: current_user) }

  before do
    allow(FilterManager).to receive(:filter_logs).and_return visible_logs
  end

  it "exposes the log type" do
    expect(delete_logs_form.log_type).to be log_type
  end

  it "exposes the search term" do
    expect(delete_logs_form.search_term).to be search_term
  end

  it "exposes the paths" do
    expect(delete_logs_form.delete_confirmation_path).to be delete_confirmation_path
    expect(delete_logs_form.back_to_logs_path).to be back_to_logs_path
    expect(delete_logs_form.delete_path).to be delete_path
  end

  it "exposes the logs returned by the filter manager" do
    expect(delete_logs_form.logs).to be visible_logs
  end

  it "exposes the selected ids" do
    expect(delete_logs_form.selected_ids).to be selected_ids
  end

  context "when selected ids are not provided to the initializer" do
    let(:selected_ids) { nil }

    it "sets the selected ids to be all logs" do
      expect(delete_logs_form.selected_ids).to match_array visible_logs.map(&:id)
    end
  end

  it "calls the filter manager with the correct arguments" do
    create(:lettings_log)

    expect(FilterManager).to receive(:filter_logs) { |arg1, arg2, arg3, arg4, arg5|
      expect(arg1).to contain_exactly(*visible_logs)
      expect(arg2).to eq search_term
      expect(arg3).to eq log_filters
      expect(arg4).to be nil
      expect(arg5).to be current_user
    }.and_return visible_logs
    delete_logs_form
  end

  it "exposes the number of logs" do
    expect(delete_logs_form.log_count).to be visible_logs.count
  end

  it "provides the name of the table partial relevant to the log type" do
    expect(delete_logs_form.table_partial_name).to eq "logs/delete_logs_table_lettings"
  end
end
