if Rails.env.staging?
  require "timecop"
  Timecop.travel(Time.zone.local(2026, 4, 1))
end
