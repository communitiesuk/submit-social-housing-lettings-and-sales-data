class Form::Sales::Questions::PrivacyNotice < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "privacynotice"
    @check_answer_label = "Buyer has seen the privacy notice?"
    @header = "Declaration"
    @guidance_partial = "test"
    @type = "checkbox"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "privacynotice" => { "value" => "The tenant has seen the DLUHC privacy notice" },
  }.freeze
end
