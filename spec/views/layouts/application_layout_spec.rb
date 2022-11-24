require "rails_helper"

RSpec.describe "layouts/application" do
  shared_examples "analytics cookie elements" do |banner:, scripts:|
    define_negated_matcher :not_match, :match

    it "#{banner ? 'includes' : 'omits'} the cookie banner" do
      banner_text = "We’d like to use analytics cookies so we can understand how you use the service and make improvements."
      if banner
        expect(rendered).to match(banner_text)
      else
        expect(rendered).not_to match(banner_text)
      end
    end

    it "#{scripts ? 'includes' : 'omits'} the analytics scripts" do
      gtm_script_tag = /<script.*googletagmanager/
      gtm_iframe_tag = /<iframe.*googletagmanager/
      if scripts
        expect(rendered).to match(gtm_script_tag).and match(gtm_iframe_tag)
      else
        expect(rendered).to not_match(gtm_script_tag).and not_match(gtm_iframe_tag)
      end
    end
  end

  context "with no cookie set" do
    before do
      cookies[:accept_analytics_cookies] = nil
      render
    end

    include_examples "analytics cookie elements", banner: true, scripts: false

    it "sets window.analyticsScript for the JS to refer to if the user accepts" do
      expect(rendered).to match(/window\.analyticsScript = "https:\/\/www\.googletagmanager\.com\/gtag\/js\?id=G-[\w\d]+"/)
    end
  end

  context "with analytics accepted" do
    before do
      cookies[:accept_analytics_cookies] = "on"
      render
    end

    include_examples "analytics cookie elements", banner: false, scripts: true
  end

  context "with analytics rejected" do
    before do
      cookies[:accept_analytics_cookies] = "off"
      render
    end

    include_examples "analytics cookie elements", banner: false, scripts: false
  end
end
