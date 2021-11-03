module Homeless
  @@homeless = {
    "Yes - assessed as homeless by a local authority and owed a homelessness duty. Including if threatened with homelessness within 56 days" => 11,
    "Yes - other homelessness" => 7,
    "No" => 1,
  }

  def self.homeless
    @@homeless
  end
end
