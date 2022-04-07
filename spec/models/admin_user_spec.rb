require "rails_helper"

RSpec.describe AdminUser, type: :model do
  describe "#new" do
    it "requires a phone number" do
      expect {
        described_class.create!(
          email: "admin_test@example.com",
          password: "password123",
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires a numerical phone number" do
      expect {
        described_class.create!(
          email: "admin_test@example.com",
          password: "password123",
          phone: "string",
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires an email" do
      expect {
        described_class.create!(
          password: "password123",
          phone: "075752137",
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires a password" do
      expect {
        described_class.create!(
          email: "admin_test@example.com",
          phone: "075752137",
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "can be created" do
      expect {
        described_class.create!(
          email: "admin_test@example.com",
          password: "password123",
          phone: "075752137",
        )
      }.to change(described_class, :count).by(1)
    end
  end

  describe "paper trail" do
    let(:admin_user) { FactoryBot.create(:admin_user) }

    it "creates a record of changes to a log" do
      expect { admin_user.update!(phone: "09673867853") }.to change(admin_user.versions, :count).by(1)
    end

    it "allows case logs to be restored to a previous version" do
      admin_user.update!(phone: "09673867853")
      expect(admin_user.paper_trail.previous_version.phone).to eq("07563867654")
    end

    it "signing in does not create a new version" do
      expect {
        admin_user.update!(
          last_sign_in_at: Time.zone.now,
          current_sign_in_at: Time.zone.now,
          current_sign_in_ip: "127.0.0.1",
          last_sign_in_ip: "127.0.0.1",
          failed_attempts: 3,
          unlock_token: "dummy",
          locked_at: Time.zone.now,
          reset_password_token: "dummy",
          reset_password_sent_at: Time.zone.now,
          remember_created_at: Time.zone.now,
          sign_in_count: 5,
          updated_at: Time.zone.now,
        )
      }.not_to change(admin_user.versions, :count)
    end
  end
end
