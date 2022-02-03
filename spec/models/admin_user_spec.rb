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
