require "rails_helper"

RSpec.describe DuplicateLogsController, type: :request do
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:user) { create(:user) }

  context "when a user is signed in" do
    let(:lettings_log) do
      create(
        :lettings_log,
        created_by: user,
      )
    end

    before do
      allow(user).to receive(:need_two_factor_authentication?).and_return(false)
      sign_in user
    end

    describe "GET" do
      context "with multiple duplicate logs" do
        let(:duplicate_logs) { create_list(:lettings_log, 2) }

        before do
          allow(LettingsLog).to receive(:duplicate_logs_for_organisation).and_return(duplicate_logs)
          get "/lettings-logs/#{lettings_log.id}/duplicate-logs"
        end

        it "displays links to all the duplicate logs" do
          expect(page).to have_link("Log #{lettings_log.id}", href: "/lettings-logs/#{lettings_log.id}")
          expect(page).to have_link("Log #{duplicate_logs.first.id}", href: "/lettings-logs/#{duplicate_logs.first.id}")
          expect(page).to have_link("Log #{duplicate_logs.second.id}", href: "/lettings-logs/#{duplicate_logs.second.id}")
        end
      end
    end
  end
end
