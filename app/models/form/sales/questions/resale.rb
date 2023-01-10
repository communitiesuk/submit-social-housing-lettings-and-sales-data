class Form::Sales::Questions::Resale < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "resale"
    @check_answer_label = "Is this a resale?"
    @header = "Is this a resale?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "If the social landlord has previously sold the property to another buyer and is now reselling the property, select 'yes'. If this is the first time the property has been sold, select 'no'."
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
