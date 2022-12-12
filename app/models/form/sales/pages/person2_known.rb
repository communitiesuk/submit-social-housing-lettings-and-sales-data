class Form::Sales::Pages::Person2Known < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_known"
    @header_partial = "person_2_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 2, "details_known_1" => 1  },
      { "hholdcount" => 3, "details_known_1" => 1  },
      { "hholdcount" => 4, "details_known_1" => 1  },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2Known.new(nil, nil, self),
    ]
  end
end
