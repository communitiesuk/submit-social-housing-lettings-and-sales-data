class Form::Sales::Questions::LivingBeforePurchase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "proplen"
    @check_answer_label = "Number of years living in the property before purchase"
    @header = "How long did the buyer(s) live in the property before purchase?"
    @hint_text = "You should round this up to the nearest year. If the buyers haven't been living in the property, enter '0'"
    @type = "numeric"
    @min = 0
    @max = 80
    @step = 1
    @width = 5
    @suffix = " years"
  end
end
