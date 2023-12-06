require "rails_helper"

RSpec.describe MergeCompletionMailer do
  let(:notify_client) { instance_double(Notifications::Client) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  describe "#send_merged_organisation_success_mail" do
    let(:merge_date) { Time.zone.local(2023, 1, 1) }

    it "sends a merge completion E-mail via notify" do
      expect(notify_client).to receive(:send_email).with(hash_including({
        template_id: MergeCompletionMailer::MERGE_COMPLETION_MERGING_ORGANISATION_TEMPLATE_ID,
        personalisation: hash_including({
          merged_organisation_name: "merged organisation",
          absorbing_organisation_name: "absorbing organisation",
          merge_date: "1 January 2023",
          email: "user@example.com",
        }),
      }))

      described_class.new.send_merged_organisation_success_mail("user@example.com", "merged organisation", "absorbing organisation", merge_date)
    end
  end

  describe "#send_absorbing_organisation_success_mail" do
    let(:merge_date) { Time.zone.local(2023, 1, 1) }

    it "sends a merge completion E-mail via notify for a single merge" do
      expect(notify_client).to receive(:send_email).with(hash_including({
        template_id: MergeCompletionMailer::MERGE_COMPLETION_ABSORBING_ORGANISATION_TEMPLATE_ID,
        personalisation: hash_including({
          organisation_count: "1 organisation",
          merged_organisations: "The organisation is merged organisation",
          absorbing_organisation_name: "absorbing organisation",
          merge_date: "1 January 2023",
          pluralised_organisation: "this organisation",
        }),
      }))

      described_class.new.send_absorbing_organisation_success_mail("user@example.com", ["merged organisation"], "absorbing organisation", merge_date)
    end

    it "sends a merge completion E-mail via notify for a multiple org merge" do
      expect(notify_client).to receive(:send_email).with(hash_including({
        template_id: MergeCompletionMailer::MERGE_COMPLETION_ABSORBING_ORGANISATION_TEMPLATE_ID,
        personalisation: hash_including({
          organisation_count: "2 organisations",
          merged_organisations: "The organisations are merged organisation and other organisation",
          absorbing_organisation_name: "absorbing organisation",
          merge_date: "1 January 2023",
          pluralised_organisation: "these organisations",
        }),
      }))

      described_class.new.send_absorbing_organisation_success_mail("user@example.com", ["merged organisation", "other organisation"], "absorbing organisation", merge_date)
    end
  end
end
