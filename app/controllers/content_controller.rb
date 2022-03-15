class ContentController < ApplicationController
  include ContentHelper

  def accessibility_statement
    render_content_page :accessibility_statement
  end

  def privacy_notice
    render_content_page :privacy_notice, page_title: "Privacy notice for tenants and buyers of new social housing"
  end
end
