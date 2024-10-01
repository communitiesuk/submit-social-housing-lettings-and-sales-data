require "rails_helper"

RSpec.describe BulkUploadSummaryComponent, type: :component do
  let(:user) { create(:user) }
  let(:support_user) { create(:user, :support) }
  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2024, total_logs_count: 10) }

  it "shows the file name" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_content(bulk_upload.filename)
  end

  it "shows the collection year" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_content("2024/2025")
  end

  it "includes a download file link" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_link("Download file", href: "/lettings-logs/bulk-uploads/#{bulk_upload.id}/download")
  end

  it "shows the total log count" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_content("10 total logs")
  end

  it "shows the uploaded by user" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_content("Uploaded by: #{bulk_upload.user.name}")
  end

  it "shows the uploading organisation" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_content("Uploading organisation: #{bulk_upload.user.organisation.name}")
  end

  it "shows the time of upload" do
    result = render_inline(described_class.new(bulk_upload:))
    expect(result).to have_content("Time of upload: #{bulk_upload.created_at.to_formatted_s(:govuk_date_and_time)}")
  end

  context "when bulk upload has only critical errors" do
    let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2, category: nil) }
    let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, total_logs_count: 10) }

    it "shows the critical errors status and error count" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Critical errors in CSV")
      expect(result).to have_content("2 critical errors")
      expect(result).to have_no_content("errors on important")
      expect(result).to have_no_content("potential")
    end

    it "includes a view error report link" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_link("View error report", href: "/lettings-logs/bulk-upload-results/#{bulk_upload.id}")
    end
  end

  context "when bulk upload has only potential errors" do
    let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2, category: "soft_validation") }
    let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, total_logs_count: 16) }

    it "shows the potential errors status and error count" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Potential errors in CSV")
      expect(result).to have_content("2 potential errors")
      expect(result).to have_content("16 total logs")
      expect(result).to have_no_content("errors on important")
      expect(result).to have_no_content("critical")
    end
  end

  context "when bulk upload has only errors on important questions" do
    let(:bulk_upload_errors) { create_list(:bulk_upload_error, 2, category: "setup") }
    let(:bulk_upload) { create(:bulk_upload, :lettings, user:, bulk_upload_errors:, total_logs_count: 16) }

    it "shows the errors on important questions status and error count" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Errors on important questions in CSV")
      expect(result).to have_content("2 errors on important questions")
      expect(result).to have_content("16 total logs")
      expect(result).to have_no_content("potential")
      expect(result).to have_no_content("critical")
    end

    it "includes a view error report link to the summary page" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_link("View error report", href: %r{.*/lettings-logs/bulk-upload-results/#{bulk_upload.id}/summary})
    end
  end

  context "when a bulk upload is uploaded with no errors" do
    let(:bulk_upload) { create(:bulk_upload, :sales, user:, total_logs_count: 1) }

    it "shows the logs uploaded with no errors status and no error counts" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Logs uploaded with no errors")
      expect(result).to have_content("1 total log")
      expect(result).to have_no_content("important questions")
      expect(result).to have_no_content("potential")
      expect(result).to have_no_content("critical")
    end
  end

  context "when a bulk upload is uploaded with errors" do
    let(:bulk_upload_errors) { create_list(:bulk_upload_error, 1) }
    let(:bulk_upload) { create(:bulk_upload, :sales, user:, bulk_upload_errors:, total_logs_count: 21) }

    before do
      create_list(:sales_log, 21, bulk_upload:)
    end

    it "shows the logs upload with errors status and error count" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Logs uploaded with errors")
      expect(result).to have_content("21 total logs")
      expect(result).to have_content("1 critical error")
      expect(result).to have_no_content("important questions")
      expect(result).to have_no_content("potential")
    end
  end

  context "when a bulk upload uses the wrong template" do
    let(:bulk_upload) { create(:bulk_upload, :sales, user:, failed: 2) }

    it "shows the wrong template status and no error counts" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Wrong template")
      expect(result).to have_no_content("important questions")
      expect(result).to have_no_content("potential")
      expect(result).to have_no_content("critical")
    end
  end

  context "when a bulk upload uses a blank template" do
    let(:bulk_upload) { create(:bulk_upload, :sales, user:, failed: 1) }

    it "shows the wrong template status and no error counts" do
      result = render_inline(described_class.new(bulk_upload:))
      expect(result).to have_content("Blank template")
      expect(result).to have_no_content("important questions")
      expect(result).to have_no_content("potential")
      expect(result).to have_no_content("critical")
    end
  end
end
