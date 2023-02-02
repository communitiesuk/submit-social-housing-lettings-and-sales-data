class Form::Lettings::Questions::Declaration < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "declaration"
    @check_answer_label = "Tenant has seen the privacy notice"
    @header = ""
    @type = "checkbox"
    @check_answers_card_number = 0
    @guidance_partial = "privacy_notice_tenant"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "declaration" => { "value" => "The tenant has seen the DLUHC privacy notice" } }.freeze
end
