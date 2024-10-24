require "rails_helper"

RSpec.describe "logs/edit.html.erb" do
  let(:current_user) { create(:user, :support) }

  before do
    Timecop.freeze(Time.zone.local(2024, 3, 1))
    Singleton.__init__(FormHandler)
    assign(:log, log)
    sign_in current_user
  end

  after do
    Timecop.return
    Singleton.__init__(FormHandler)
  end

  context "when log is in progress" do
    let(:log) { create(:lettings_log, :in_progress) }

    it "there is no link back to log type root" do
      render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

      fragment = Capybara::Node::Simple.new(rendered)

      expect(fragment).not_to have_link(text: "Back to lettings logs", href: "/lettings-logs")
    end

    it "has link 'Delete log'" do
      render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

      fragment = Capybara::Node::Simple.new(rendered)

      expect(fragment).to have_link(text: "Delete log", href: "/lettings-logs/#{log.id}/delete-confirmation")
    end
  end

  context "when log is completed" do
    context "when showing a lettings log" do
      let(:log) { create(:lettings_log, :completed) }

      it "has link 'Back to lettings logs'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Back to lettings logs", href: "/lettings-logs")
      end

      it "has link 'Delete log'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Delete log", href: "/lettings-logs/#{log.id}/delete-confirmation")
      end
    end

    context "when showing a sales log" do
      let(:log) { create(:sales_log, :completed) }

      it "has link 'Back to sales logs'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Back to sales logs", href: "/sales-logs")
      end

      it "has link 'Delete log'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Delete log", href: "/sales-logs/#{log.id}/delete-confirmation")
      end
    end

    context "when lettings log is bulk uploaded" do
      let(:bulk_upload) { create(:bulk_upload, :lettings) }
      let(:log) { create(:lettings_log, :completed, bulk_upload:, creation_method: "bulk upload") }

      it "has link 'Back to uploaded logs'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: true }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Back to uploaded logs", href: "/lettings-logs/bulk-upload-results/#{bulk_upload.id}/resume")
      end

      it "has link 'Delete log'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: true }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Delete log", href: "/lettings-logs/#{log.id}/delete-confirmation")
      end
    end

    context "when lettings log is bulk uploaded without a bulk upload id" do
      let(:log) { create(:lettings_log, :completed, bulk_upload: nil, creation_method: "bulk upload") }

      it "does not have link 'Back to uploaded logs'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: false }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).not_to have_link(text: "Back to uploaded logs")
      end
    end

    context "when sales log is bulk uploaded" do
      let(:bulk_upload) { create(:bulk_upload, :sales) }
      let(:log) { create(:sales_log, :completed, bulk_upload:, creation_method: "bulk upload") }

      it "has link 'Back to uploaded logs'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: true }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Back to uploaded logs", href: "/sales-logs/bulk-upload-results/#{bulk_upload.id}/resume")
      end

      it "has link 'Delete log'" do
        render template: "logs/edit", locals: { current_user:, bulk_upload_filter_applied: true }

        fragment = Capybara::Node::Simple.new(rendered)

        expect(fragment).to have_link(text: "Delete log", href: "/sales-logs/#{log.id}/delete-confirmation")
      end
    end
  end
end
