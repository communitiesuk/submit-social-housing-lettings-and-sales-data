class Form::Sales::Questions::Prevown < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "prevown"
    @check_answer_label = "Buyer#{'s' if joint_purchase} previously owned a property"
    @header = "#{joint_purchase ? 'Have any of the buyers' : 'Has the buyer'} previously owned a property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
