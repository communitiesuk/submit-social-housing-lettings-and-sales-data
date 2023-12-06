require "rails_helper"

RSpec.describe MergeCompletionMailer do
  let(:notify_client) { instance_double(Notifications::Client) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_merge_completion_mail" do
    let(:merge_date) { Time.zone.today }

    it "sends a merge completion E-mail via notify" do
      expect(notify_client).to receive(:send_email).with(hash_including({ personalisation: hash_including({
        merged_organisation_name: "merged organisation",
        absorbing_organisation_name: "absorbing organisation",
        merge_date:,
        email: "user@example.com",
        username: "user",
      }) }))

      described_class.new.send_merge_completion_mail("user@example.com", "merged organisation", "absorbing organisation", merge_date, "user")
    end
  end
end
