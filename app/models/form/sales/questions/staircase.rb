class Form::Sales::Questions::Staircase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircase"
    @check_answer_label = "Staircasing transaction"
    @header = "Q76 - Is this a staircasing transaction?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "A staircasing transaction is when the household purchases more shares in their property, increasing the proportion they own and decreasing the proportion the housing association owns. Once the household purchases 100% of the shares, they own the property"
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
