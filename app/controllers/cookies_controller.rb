# frozen_string_literal: true

class CookiesController < ApplicationController
  before_action :set_cookie_form, only: :show

  def show; end

  def update
    analytics_consent = params[:cookies_form][:analytics_consent]
    if %w[on off].include?(analytics_consent)
      cookies[:accept_analytics_cookies] = { value: analytics_consent, expires: 1.year.from_now }
    end

    respond_to do |format|
      format.html do
        set_cookie_form
        flash[:notice] = "You’ve set your cookie preferences."

        redirect_to cookies_path
      end
    end
  end

private

  def set_cookie_form
    @cookies_form = CookiesForm.new(accept_analytics_cookies: cookies[:accept_analytics_cookies])
  end
end
