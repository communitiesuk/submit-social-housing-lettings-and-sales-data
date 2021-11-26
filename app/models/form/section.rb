class Form::Section
  attr_accessor :id, :label, :subsections, :form

  def initialize(id, hsh, form)
    @id = id
    @label = hsh["label"]
    @form = form
    @subsections = hsh["subsections"].map { |id, s| Form::Subsection.new(id, s, self) }
  end
end
