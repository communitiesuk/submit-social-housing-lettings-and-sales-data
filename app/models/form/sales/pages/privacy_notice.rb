class Form::Sales::Pages::PrivacyNotice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "privacy_notice"
    @header = "Department for Levelling Up, Housing and Communities privacy notice"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "noint" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PrivacyNotice.new(nil, nil, self),
    ]
  end
end
