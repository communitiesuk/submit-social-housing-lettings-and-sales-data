class Form::Sales::Questions::SharedOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @check_answer_label = "Type of shared ownership sale"
    @header = "What is the type of shared ownership sale?"
    @hint_text = "A shared ownership sale is when the purchaser buys up to 75% of the property value and pays rent to the Private Registered Provider (PRP) on the remaining portion"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Shared Ownership" },
    "24" => { "value" => "Old Persons Shared Ownership" },
    "18" => { "value" => "Social HomeBuy (shared ownership purchase)" },
    "16" => { "value" => "Home Ownership for people with Long Term Disabilities (HOLD)" },
    "28" => { "value" => "Rent to Buy - Shared Ownership" },
    "31" => { "value" => "Right to Shared Ownership" },
    "30" => { "value" => "Shared Ownership - 2021 model lease" },
  }.freeze
end
