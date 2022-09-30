class Form::Sales::Questions::OtherBuyer2RelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "otherrelat2"
    @check_answer_label = "Buyer 2's relationship to buyer 1"
    @header = "Buyer 2's relationship to buyer 1"
    @type = "text"
    @page = page
  end
end
