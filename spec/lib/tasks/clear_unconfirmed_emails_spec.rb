require "rails_helper"
require "rake"

RSpec.describe "clear_unconfirmed_emails" do
  describe ":clear_unconfirmed_emails", type: :task do
    subject(:task) { Rake::Task["clear_unconfirmed_emails"] }

    before do
      Rake.application.rake_require("tasks/clear_unconfirmed_emails")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there are deactivated users with unconfirmed emails" do
        let!(:user) { create(:user, active: false, unconfirmed_email: "some_email@example.com") }

        it "clears unconfirmed_email" do
          task.invoke

          expect(user.reload.unconfirmed_email).to eq(nil)
        end
      end

      context "and there are active users with unconfirmed emails" do
        let!(:user) { create(:user, active: true, unconfirmed_email: "some_email@example.com") }

        it "does not clear unconfirmed_email" do
          task.invoke

          expect(user.reload.unconfirmed_email).not_to eq(nil)
        end
      end
    end
  end
end
