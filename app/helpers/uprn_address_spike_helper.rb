# frozen_string_literal: true

module UprnAddressSpikeHelper
  def match_colour(match)
    if match == 1
      "purple"
    elsif match >= 0.8
      "green"
    elsif match >= 0.7
      "orange"
    else
      "red"
    end
  end
end
