class Form::Sales::Questions::BuyerPrevious < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "soctenant"
    @check_answer_label = "#{joint_purchase ? 'Any buyers were' : 'Buyer was a'} registered provider#{'s' if joint_purchase}, housing association or local authority tenant#{'s' if joint_purchase} immediately before this sale?"
    @header = "#{joint_purchase ? 'Were any of the buyers' : 'Was the buyer a'} private registered provider#{'s' if joint_purchase}, housing association or local authority tenant#{'s' if joint_purchase} immediately before this sale?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
