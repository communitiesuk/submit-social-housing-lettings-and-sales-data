require "rails_helper"

RSpec.describe "routes.rb" do
  let(:all_routes) do
    Rails.application.routes.routes.map { |r| r.path.spec.to_s if r.defaults[:controller] }.compact
  end
  let(:active_admin_routes_prefix) { "/admin" }
  let(:rails_routes_prefix) { "/rails" }
  let(:turbo_routes_pattern) { "_historical_location" }
  let(:project_routes) do
    all_routes.reject do |r|
      r.starts_with?(active_admin_routes_prefix) || r.starts_with?(rails_routes_prefix) ||
        r.include?(turbo_routes_pattern)
    end
  end

  it "does not use underscores" do
    routes_with_underscores = project_routes.select do |r|
      r.split("/").any? { |component| !component.start_with?(":") && component.match("_") }
    end
    expect(routes_with_underscores).to be_empty
  end
end
