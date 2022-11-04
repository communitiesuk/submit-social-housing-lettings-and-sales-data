# frozen_string_literal: true

class CookiesForm
  include ActiveModel::Model

  attr_accessor :accept_analytics_cookies

  def consent_options
    [
      OpenStruct.new(id: "on", name: "Yes"),
      OpenStruct.new(id: "off", name: "No"),
    ]
  end
end
