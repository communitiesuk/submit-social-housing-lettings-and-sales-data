class Form::Lettings::Questions::Rsnvac < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rsnvac"
    @check_answer_label = "Vacancy reason"
    @header = "What is the reason for the property being vacant?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "13" => {
      "value" => "Internal transfer",
      "hint" => "Excluding renewals of a fixed-term tenancy",
    },
    "5" => {
      "value" => "Previous tenant died with no succession",
    },
    "9" => {
      "value" => "Re-let to tenant who occupied same property as temporary accommodation",
    },
    "14" => {
      "value" => "Renewal of fixed-term tenancy",
    },
    "19" => {
      "value" => "Tenant involved in a succession downsize",
    },
    "8" => {
      "value" => "Tenant moved to private sector or other accommodation",
    },
    "12" => {
      "value" => "Tenant moved to other social housing provider",
    },
    "18" => {
      "value" => "Tenant moved to care home",
    },
    "20" => {
      "value" => "Tenant moved to long-stay hospital or similar institution",
    },
    "6" => {
      "value" => "Tenant abandoned property",
    },
    "10" => {
      "value" => "Tenant was evicted due to rent arrears",
    },
    "11" => {
      "value" => "Tenant was evicted due to anti-social behaviour",
    },
  }.freeze
end
