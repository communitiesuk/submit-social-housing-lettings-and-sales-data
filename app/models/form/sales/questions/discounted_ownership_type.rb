class Form::Sales::Questions::DiscountedOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @check_answer_label = "Type of discounted ownership sale"
    @header = "What is the type of discounted ownership sale?"
    @hint_text = "A discounted ownership sale is when the purchaser buys up to 75% of the property value and pays rent to the Private Registered Provider (PRP) on the remaining portion"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "8" => { "value" => "Right to Aquire (RTA)" },
    "14" => { "value" => "Preserved Right to Buy (PRTB)" },
    "27" => { "value" => "Voluntary Right to Buy (VRTB)" },
    "9" => { "value" => "Right to Buy (RTB)" },
    "29" => { "value" => "Rent to Buy - Full Ownership" },
    "21" => { "value" => "Social HomeBuy for outright purchase" },
    "22" => { "value" => "Any other equity loan scheme" },
  }.freeze
end
