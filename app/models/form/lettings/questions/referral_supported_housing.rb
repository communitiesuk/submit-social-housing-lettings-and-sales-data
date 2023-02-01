class Form::Lettings::Questions::ReferralSupportedHousing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "referral"
    @check_answer_label = "Source of referral for letting"
    @header = "What was the source of referral for this letting?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => {
      "value" => "Internal transfer",
    },
    "2" => {
      "value" => "Tenant applied directly (no referral)",
    },
    "3" => {
      "value" => "Referred by local authority housing department",
    },
    "8" => {
      "value" => "Re-located through official housing mobility scheme",
    },
    "10" => {
      "value" => "Other social landlord",
    },
    "9" => {
      "value" => "Community learning disability team",
    },
    "14" => {
      "value" => "Community mental health team",
    },
    "15" => {
      "value" => "Health service",
    },
    "12" => {
      "value" => "Police, probation or prison",
    },
    "7" => {
      "value" => "Voluntary agency",
    },
    "13" => {
      "value" => "Youth offending team",
    },
    "16" => {
      "value" => "Other",
    },
  }.freeze
end
