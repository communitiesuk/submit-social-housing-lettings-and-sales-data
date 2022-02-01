require "rails_helper"

RSpec.describe ErrorSummaryFullMessagesPresenter do
  subject(:error_summary_presenter) { described_class.new(error_messages) }

  let(:error_messages) { { reset_password_token: %w[expired] } }
  let(:formatted_error_messages) { [[:reset_password_token, "Reset password token expired"]] }

  it "formats messages to include the attribute name" do
    expect(error_summary_presenter.formatted_error_messages).to eq(formatted_error_messages)
  end
end
