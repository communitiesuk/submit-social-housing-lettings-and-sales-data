class Form::Sales::Questions::GenderIdentity1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex1"
    @check_answer_label = "Buyer 1’s gender identity"
    @header = "Which of these best describes buyer 1’s gender identity?"
    @type = "radio"
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @page = page
  end
end
