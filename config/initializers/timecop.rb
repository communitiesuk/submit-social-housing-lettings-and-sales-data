if Rails.env.staging? || Rails.env.review?
  require "timecop"
  Timecop.travel(Time.zone.local(2026, 4, 1))
end
