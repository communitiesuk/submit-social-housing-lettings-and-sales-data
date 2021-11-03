module Ecstat
  @@ecstat = {
    "Part-time - Less than 30 hours" => 2,
    "Full-time - 30 hours or more" => 1,
    "In government training into work, such as New Deal" => 3,
    "Jobseeker" => 4,
    "Retired" => 5,
    "Not seeking work" => 6,
    "Full-time student" => 7,
    "Unable to work because of long term sick or disability" => 8,
    "Child under 16" => 100,
    "Other" => 0,
    "Prefer not to say" => 10,
  }

  def self.ecstat
    @@ecstat
  end
end
