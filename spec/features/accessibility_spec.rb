require "rails_helper"

RSpec.describe "Accessibility", js: true do
  let(:user) { create(:user, :support) }
  let!(:other_user) { create(:user, name: "new user", organisation: user.organisation, email: "new_user@example.com", confirmation_token: "abc") }
  let(:storage_service) { instance_double(Storage::S3Service, get_file_metadata: nil) }

  def find_routes(type, resource, subresource)
    routes = Rails.application.routes.routes.select do |route|
      route.verb == "GET" && route.path.spec.to_s.start_with?("/#{type}")
    end

    routes.map do |route|
      route_path = route.path.spec.to_s
      route_path
        .gsub("/#{type}s/:id", "/#{type}s/#{resource.id}")
        .gsub(":#{type.underscore}_id", resource.id.to_s)
        .gsub(":id", subresource.id.to_s)
        .gsub("(.:format)", "")
    end
  end

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(storage_service).to receive(:configuration).and_return(OpenStruct.new(bucket_name: "core-test-collection-resources"))
    allow(user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in(user)
  end

  context "when viewing user pages" do
    let(:user_paths) do
      Rails.application.routes.routes.select { |route| route.verb == "GET" && route.path.spec.to_s.start_with?("/user") }.map { |route|
        route_path = route.path.spec.to_s
        route_path.gsub(":id", other_user.id.to_s).gsub(":user_id", other_user.id.to_s).gsub("(.:format)", "")
        .gsub("log-reassignment", "log-reassignment?&organisation_id=#{other_user.organisation_id}")
        .gsub("organisation-change-confirmation", "organisation-change-confirmation?&organisation_id=#{other_user.organisation_id}&log_reassignment=reassign_all")
      }.uniq
    end

    before do
      create(:lettings_log, assigned_to: other_user)
    end

    it "is has accessible pages" do
      user_paths.each do |path|
        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing organisation pages" do
    let(:parent_relationship) { create(:organisation_relationship, parent_organisation: other_user.organisation) }
    let(:child_relationship) { create(:organisation_relationship, child_organisation: other_user.organisation) }
    let(:organisation_paths) do
      routes = find_routes("organisation", other_user.organisation, other_user.organisation).reject do |route|
        route.match?(/\A\/organisations\/#{other_user.organisation_id}\z/) ||
          route.include?("filters/update")
      end
      routes << "/organisations/#{other_user.organisation_id}/details"
      route_mappings = {
        "/schemes/csv-download" => "?download_type=combined",
        "logs/csv-download" => "?codes_only=false&years[]=2024",
        "filters/update" => "?codes_only=false",
        "stock-owners/remove" => "?target_organisation_id=#{child_relationship.parent_organisation.id}",
        "managing-agents/remove" => "?target_organisation_id=#{parent_relationship.child_organisation.id}",
      }

      routes.map do |route|
        additional_params = route_mappings.find { |pattern, _| route.include?(pattern) }&.last
        route += additional_params if additional_params
        route
      end
    end

    it "is has accessible pages" do
      organisation_paths.each do |path|
        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing lettings log pages" do
    let(:bulk_upload) { create(:bulk_upload, user:) }
    let(:lettings_log) { create(:lettings_log, :completed, assigned_to: other_user, bulk_upload_id: bulk_upload.id) }
    let(:organisation_relationship) { create(:organisation_relationship, parent_organisation: user.organisation) }

    let(:lettings_log_paths) do
      routes = find_routes("lettings-log", lettings_log, bulk_upload)
      all_page_ids = FormHandler.instance.lettings_forms.values.flat_map(&:pages).map(&:id).uniq
      lettings_log_pages = lettings_log.form.pages
      other_form_page_ids = all_page_ids - lettings_log_pages.map(&:id)

      routes.reject { |path|
        path.include?("/edit") || path.include?("/new") || path.include?("*page") || path.include?("filters/update") ||
          path.include?("local-authority/check-answers") || path.include?("declaration/check-answers") ||
          path.include?("/lettings-logs/bulk-upload-logs/#{bulk_upload.id}") ||
          path.include?("bulk-upload-soft-validations-check") ||
          path == "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}" ||
          other_form_page_ids.any? { |page_id| path.include?(page_id.dasherize) } ||
          lettings_log_pages.any? { |page| path.include?(page.id.dasherize) && !page.routed_to?(lettings_log, user) }
      }.uniq
    end

    before do
      lettings_log.dup.tap do |log|
        log.save(validate: false)
      end
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
      allow(storage_service).to receive(:get_presigned_url).with(bulk_upload.identifier, 60, response_content_disposition: "attachment; filename=#{bulk_upload.filename}").and_return("http://example.com/lettings-logs/bulk-uploads/#{bulk_upload.id}/download")
    end

    it "is has accessible pages" do
      lettings_log_paths.each do |path|
        path += "?original_log_id=#{lettings_log.id}" if path.include?("duplicate")
        path += "?codes_only=true&years[]=2024" if path.include?("csv")
        path.gsub!("/start", "/prepare-your-file?form[year]=2024") if path.include?("bulk-upload-logs/start")
        path.gsub!("/start", "/fix-choice") if path.include?("/bulk-upload-resume/#{bulk_upload.id}/start")
        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing sales log pages" do
    let(:bulk_upload) { create(:bulk_upload, user:) }
    let(:sales_log) { create(:sales_log, :completed, assigned_to: other_user, bulk_upload_id: bulk_upload.id) }
    let(:organisation_relationship) { create(:organisation_relationship, parent_organisation: user.organisation) }

    let(:sales_log_paths) do
      all_page_ids = FormHandler.instance.sales_forms.values.flat_map(&:pages).map(&:id).uniq
      sales_log_pages = sales_log.form.pages
      other_form_page_ids = all_page_ids - sales_log_pages.map(&:id)

      routes = find_routes("sales-log", sales_log, bulk_upload)

      routes.reject { |path|
        path.include?("/edit") || path.include?("/new") || path.include?("*page") ||
          path.include?("/sales-logs/bulk-upload-logs/#{bulk_upload.id}") ||
          path.include?("bulk-upload-soft-validations-check") || path.include?("filters/update") ||
          path == "/sales-logs/bulk-upload-resume/#{bulk_upload.id}" ||
          path == "/sales-logs/bulk-upload-logs" ||
          other_form_page_ids.any? { |page_id| path.include?(page_id.dasherize) } ||
          sales_log_pages.any? { |page| path.include?(page.id.dasherize) && !page.routed_to?(sales_log, user) }
      }.uniq
    end

    before do
      allow(storage_service).to receive(:get_presigned_url).with(bulk_upload.identifier, 60, response_content_disposition: "attachment; filename=#{bulk_upload.filename}").and_return("http://example.com/sales-logs/bulk-uploads/#{bulk_upload.id}/download")
    end

    it "is has accessible pages" do
      sales_log_paths.each do |path|
        path += "?original_log_id=#{sales_log.id}" if path.include?("duplicate")
        path += "?codes_only=true&years[]=2024" if path.include?("csv")
        path.gsub!("/start", "/prepare-your-file?form[year]=2024") if path.include?("bulk-upload-logs/start")
        path.gsub!("/start", "/fix-choice") if path.include?("/bulk-upload-resume/#{bulk_upload.id}/start")

        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing scheme pages" do
    let(:scheme) { create(:scheme, owning_organisation: other_user.organisation) }
    let!(:location) { create(:location, scheme:) }
    let(:scheme_paths) do
      routes = find_routes("scheme", scheme, location)

      routes.reject { |path|
        path.include?("/edit") || path.include?("/new") || path.include?("*page") ||
          path.include?("reactivate") || path.include?("deactivate")
      }.uniq
    end

    before do
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
    end

    it "is has accessible pages" do
      scheme_paths.each do |path|
        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing other pages" do
    [{ path: "/", title: "homepage" },
     { path: "/guidance", title: "guidance" },
     { path: "/privacy-notice", title: "privacy notice" },
     { path: "/lettings-logs/bulk-upload-logs/guidance?form[year]=2024&referrer=home", title: "lettings BU guidance" },
     { path: "/sales-logs/bulk-upload-logs/guidance?form[year]=2024&referrer=home", title: "sales BU guidance" }].each do |test_case|
      it "is has accessible #{test_case[:title]} page" do
        visit(test_case[:path])
        expect(page).to have_current_path(test_case[:path])
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end
end
