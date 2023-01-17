class Form::Sales::Pages::PrivacyNotice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "privacy_notice"
    @header = "Department for Levelling Up, Housing and Communities privacy notice"
    @depends_on = [{
      "noint" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PrivacyNotice.new(nil, nil, self),
    ]
  end
end
