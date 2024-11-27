class Form::Sales::Questions::MortgageLender < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgagelender"
    @type = "select"
    @page = page
    @bottom_guidance_partial = "mortgage_lender"
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
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
    "41" => "Kent Reliance",
    "40" =>	"Other",
    "0" =>	"Don’t know",
  }.freeze

  OPTIONS_INTRODUCED_2024 = %w[41].freeze
  OPTIONS_NOT_DISPLAYED = %w[0].freeze

  def answer_options
    if form.start_year_2024_or_later?
      ANSWER_OPTIONS
    else
      ANSWER_OPTIONS.dup.reject { |k, _v| OPTIONS_INTRODUCED_2024.include?(k) }
    end
  end

  def displayed_answer_options(_log, _user = nil)
    answer_options.reject { |k, _v| OPTIONS_NOT_DISPLAYED.include?(k) }
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 92, 2 => 105, 3 => 113 },
    2024 => { 1 => 93, 2 => 106 },
  }.freeze
end
