class Form::Lettings::Pages::TimeLivedInLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "time_lived_in_local_authority"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Layear.new(nil, nil, self)]
  end
end
