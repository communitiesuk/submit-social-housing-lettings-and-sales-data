require "rails_helper"

RSpec.describe "routes.rb" do
  it "does not use underscores" do
    paths = Rails.application.routes.routes.map { |r| r.path.spec.to_s if r.defaults[:controller] }.compact

    # Allow underscores for ActiveAdmin, Rails and Turbo routes
    paths = paths.reject { |p| p.starts_with?("/admin") }
    paths = paths.reject { |p| p.starts_with?("/rails") }
    paths = paths.reject { |p| p.include?("_historical_location") }

    paths.each do |path|
      has_underscores = path.split("/").any? { |component| !component.start_with?(":") && component.match("_") }

      expect(has_underscores).to be(false), "#{path} should not have underscores"
    end
  end
end
