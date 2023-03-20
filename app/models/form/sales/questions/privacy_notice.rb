class Form::Sales::Questions::PrivacyNotice < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "privacynotice"
    @check_answer_label = "Buyer has seen the privacy notice?"
    @header = "Declaration"
    @type = "checkbox"
    @answer_options = ANSWER_OPTIONS
    @guidance_partial = "privacy_notice_buyer"
    @question_number = 19
  end

  ANSWER_OPTIONS = {
    "privacynotice" => { "value" => "The buyer has seen the DLUHC privacy notice" },
  }.freeze
end
