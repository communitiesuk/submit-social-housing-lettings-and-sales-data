class Form::Sales::Pages::Buyer1WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_working_situation"
    @header = "Which of these best describes buyer 1's working situation?"
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1WorkingSituation.new(nil, nil, self),
    ]
  end
end
