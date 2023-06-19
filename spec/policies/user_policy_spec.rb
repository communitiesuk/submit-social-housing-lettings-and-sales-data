require "rails_helper"
# rubocop:disable RSpec/RepeatedExample

RSpec.describe UserPolicy do
  subject(:policy) { described_class }

  let(:data_provider) { FactoryBot.create(:user, :data_provider) }
  let(:data_coordinator) { FactoryBot.create(:user, :data_coordinator) }
  let(:support) { FactoryBot.create(:user, :support) }

  permissions :edit_names? do
    it "allows changing their own name" do
      expect(policy).to permit(data_provider, data_provider)
    end

    it "as a coordinator it allows changing other user's name" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user it allows changing other user's name" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_emails? do
    it "allows changing their own email" do
      expect(policy).to permit(data_provider, data_provider)
    end

    it "as a coordinator it allows changing other user's email" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user it allows changing other user's email" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_password? do
    it "as a provider it allows changing their own password" do
      expect(policy).to permit(data_provider, data_provider)
    end

    it "as a coordinator it allows changing their own password" do
      expect(policy).to permit(data_coordinator, data_coordinator)
    end

    it "as a support user it allows changing their own password" do
      expect(policy).to permit(support, support)
    end

    it "as a coordinator it does not allow changing other user's password" do
      expect(policy).not_to permit(data_coordinator, data_provider)
    end

    it "as a support user it does not allow changing other user's password" do
      expect(policy).not_to permit(support, data_provider)
    end
  end

  permissions :edit_roles? do
    it "as a provider it does not allow changing roles" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator allows changing other user's roles" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's roles" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_dpo? do
    it "as a provider it does not allow changing dpo" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator allows changing other user's dpo" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's dpo" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_key_contact? do
    it "as a provider it does not allow changing key_contact" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator allows changing other user's key_contact" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's key_contact" do
      expect(policy).to permit(support, data_provider)
    end
  end
end
# rubocop:enable RSpec/RepeatedExample
