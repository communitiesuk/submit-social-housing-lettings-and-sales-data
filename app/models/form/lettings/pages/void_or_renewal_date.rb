class Form::Lettings::Pages::VoidOrRenewalDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "void_or_renewal_date"
    @depends_on = [{ "not_renewal?" => true, "vacancy_reason_not_renewal_or_first_let?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Voiddate.new(nil, nil, self)]
  end
end
