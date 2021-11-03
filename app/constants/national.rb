module National
  @@national = {
    "UK national resident in UK" => 1,
    "A current or former reserve in the UK Armed Forces (exc. National Service)" => 100,
    "UK national returning from residence overseas" => 2,
    "Czech Republic" => 3,
    "Estonia" => 4,
    "Hungary" => 5,
    "Latvia" => 6,
    "Lithuania" => 7,
    "Poland" => 8,
    "Slovakia" => 9,
    "Bulgaria" => 14,
    "Romania" => 15,
    "Ireland" => 17,
    "Other EU Economic Area (EEA country)" => 11,
    "Any other country" => 12,
    "Prefer not to say" => 13,
  }

  def self.national
    @@national
  end
end
