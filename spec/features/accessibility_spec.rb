require "rails_helper"

RSpec.describe "Accessibility", js: true do
  let(:user) { create(:user, :support) }
  let!(:other_user) { create(:user, name: "new user", organisation: user.organisation, email: "new_user@example.com", confirmation_token: "abc") }

  before do
    allow(user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in(user)
  end

  context "when viewing user pages" do
    let(:user_paths) {
      Rails.application.routes.routes.select {|route| route.verb == "GET" && route.path.spec.to_s.start_with?("/user")} .map do |route| 
        route_path = route.path.spec.to_s
        route_path.gsub(":id", other_user.id.to_s).gsub(":user_id", other_user.id.to_s).gsub("(.:format)", "")
      end.uniq
    }

    it "is has accessible pages" do
      user_paths.each do |path|
        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing organisation pages" do
    let(:organisation_paths) {
      Rails.application.routes.routes.select {|route| route.verb == "GET" && route.path.spec.to_s.start_with?("/organisation")} .map do |route| 
        route_path = route.path.spec.to_s
        route_path.gsub(":id", other_user.organisation_id.to_s)
        .gsub(":organisation_id", other_user.organisation_id.to_s)
        .gsub("(.:format)", "")
        .gsub(/\A\/organisations\/#{other_user.organisation_id}\z/, "/organisations/#{other_user.organisation_id}/details")
      end.uniq
    }

    it "is has accessible pages" do
      organisation_paths.each do |path|
        next if path.include?("invite") # needs to be fixed
        next if path.include?("csv") # needs to be fixed, needs codes_only
        next if path.include?("lettings-logs") # needs to be fixed
        next if path.include?("sales-logs") # needs to be fixed
        next if path.include?("stock-owner") # needs to be fixed, needs target_organisation
        next if path.include?("managing-agent") # needs to be fixed, needs target_organisation

        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing lettings log pages" do
    let(:bulk_upload) { create(:bulk_upload) }
    let(:lettings_log) { create(:lettings_log, :completed, assigned_to: other_user, bulk_upload_id: bulk_upload.id) }
    let(:organisation_relationship) {create(:organisation_relationship, parent_organisation: user.organisation) } 

    let(:lettings_log_paths) do
      all_page_ids = FormHandler.instance.lettings_forms.values.flat_map(&:pages).map(&:id).uniq
      lettings_log_pages = lettings_log.form.pages
      other_form_page_ids = all_page_ids - lettings_log_pages.map(&:id)
    
      filtered_routes = Rails.application.routes.routes.select do |route|
        route.verb == "GET" && route.path.spec.to_s.start_with?("/lettings-log")
      end
    
      filtered_routes.map do |route|
        route_path = route.path.spec.to_s
        route_path
          .gsub("/lettings-logs/:id", "/lettings-logs/#{lettings_log.id}")
          .gsub(":lettings_log_id", "#{lettings_log.id}")
          .gsub(":id", "#{bulk_upload.id}")
          .gsub("(.:format)", "")
      end.reject do |path|
        path.include?("/edit") || path.include?("/new") || path.include?("*page") ||
        path.include?("local-authority/check-answers") || path.include?("declaration/check-answers") ||
          other_form_page_ids.any? { |page_id| path.include?(page_id.dasherize) } ||
          lettings_log_pages.any? { |page| path.include?(page.id.dasherize) && !page.routed_to?(lettings_log, user) }
      end.uniq
    end
    

    before do 
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
    end

    it "is has accessible pages" do
      lettings_log_paths.each do |path|
        next if path.include?("duplicate") # needs to be fixed, add a duplicate?
        next if path.include?("csv") # needs to be fixed, needs codes_only
        next if path.include?("filters/update") # needs to be fixed, needs codes_only
        next if path.include?("bulk") # needs to be fixed

        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end

  context "when viewing sales log pages" do
    let(:bulk_upload) { create(:bulk_upload) }
    let(:sales_log) { create(:sales_log, :completed, assigned_to: other_user, bulk_upload_id: bulk_upload.id) }
    let(:organisation_relationship) {create(:organisation_relationship, parent_organisation: user.organisation) } 

    let(:sales_log_paths) do
      all_page_ids = FormHandler.instance.sales_forms.values.flat_map(&:pages).map(&:id).uniq
      sales_log_pages = sales_log.form.pages
      other_form_page_ids = all_page_ids - sales_log_pages.map(&:id)
    
      filtered_routes = Rails.application.routes.routes.select do |route|
        route.verb == "GET" && route.path.spec.to_s.start_with?("/sales-log")
      end
    
      filtered_routes.map do |route|
        route_path = route.path.spec.to_s
        route_path
          .gsub("/sales-logs/:id", "/sales-logs/#{sales_log.id}")
          .gsub(":sales_log_id", "#{sales_log.id}")
          .gsub(":id", "#{bulk_upload.id}")
          .gsub("(.:format)", "")
      end.reject do |path|
        path.include?("/edit") || path.include?("/new") || path.include?("*page") ||
          other_form_page_ids.any? { |page_id| path.include?(page_id.dasherize) } ||
          sales_log_pages.any? { |page| path.include?(page.id.dasherize) && !page.routed_to?(sales_log, user) }
      end.uniq
    end
    

    before do 
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
    end

    it "is has accessible pages" do
      sales_log_paths.each do |path|
        next if path.include?("duplicate") # needs to be fixed, add a duplicate?
        next if path.include?("csv") # needs to be fixed, needs codes_only
        next if path.include?("filters/update") # needs to be fixed, needs codes_only
        next if path.include?("bulk") # needs to be fixed

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
      filtered_routes = Rails.application.routes.routes.select do |route|
        route.verb == "GET" && route.path.spec.to_s.start_with?("/scheme")
      end
    
      filtered_routes.map do |route|
        route_path = route.path.spec.to_s
        route_path
          .gsub("/scheme/:id", "/scheme/#{scheme.id}")
          .gsub(":scheme_id", "#{scheme.id}")
          .gsub(":id", "#{location.id}")
          .gsub("(.:format)", "")
      end.reject do |path|
        path.include?("/edit") || path.include?("/new") || path.include?("*page")
      end.uniq
    end
    

    before do 
      allow(FormHandler.instance).to receive(:in_crossover_period?).and_return(true)
    end

    it "is has accessible pages" do
      scheme_paths.each do |path|
        next if path.include?("reactivate") # needs to be fixed
        next if path.include?("deactivate") # needs to be fixed

        visit(path)
        expect(page).to have_current_path(path)
        expect(page).to be_axe_clean.according_to :wcag2aa
      end
    end
  end
end
