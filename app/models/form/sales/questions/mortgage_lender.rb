class Form::Sales::Questions::MortgageLender < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "mortgagelender"
    @check_answer_label = "Mortgage Lender"
    @header = "#{question_number} - What is the name of the mortgage lender?"
    @type = "select"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
    @guidance_position = GuidancePosition::BOTTOM
    @guidance_partial = "mortgage_lender"
  end

  ANSWER_OPTIONS = {
    "" => "Select an option",
    "1" =>	"Atom Bank",
    "2" =>	"Barclays Bank PLC",
    "3" =>	"Bath Building Society",
    "4" =>	"Buckinghamshire Building Society",
    "5" =>	"Cambridge Building Society",
    "6" =>	"Coventry Building Society",
    "7" =>	"Cumberland Building Society",
    "8" =>	"Darlington Building Society",
    "9" =>	"Dudley Building Society",
    "10" =>	"Ecology Building Society",
    "11" =>	"Halifax",
    "12" =>	"Hanley Economic Building Society",
    "13" =>	"Hinckley and Rugby Building Society",
    "14" =>	"Holmesdale Building Society",
    "15" =>	"Ipswich Building Society",
    "16" =>	"Leeds Building Society",
    "17" =>	"Lloyds Bank",
    "18" =>	"Mansfield Building Society",
    "19" =>	"Market Harborough Building Society",
    "20" =>	"Melton Mowbray Building Society",
    "21" =>	"Nationwide Building Society",
    "22" =>	"Natwest",
    "23" =>	"Nedbank Private Wealth",
    "24" =>	"Newbury Building Society",
    "25" =>	"OneSavings Bank",
    "26" =>	"Parity Trust",
    "27" =>	"Penrith Building Society",
    "28" =>	"Pepper Homeloans",
    "29" =>	"Royal Bank of Scotland",
    "30" =>	"Santander",
    "31" =>	"Skipton Building Society",
    "32" =>	"Teachers Building Society",
    "33" =>	"The Co-operative Bank",
    "34" =>	"Tipton & Coseley Building Society",
    "35" =>	"TSB",
    "36" =>	"Ulster Bank",
    "37" =>	"Virgin Money",
    "38" =>	"West Bromwich Building Society",
    "39" =>	"Yorkshire Building Society",
    "40" =>	"Other",
  }.freeze
end
