class Form::Lettings::Pages::StarterTenancyType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "starter_tenancy_type"
    @depends_on = [{ "startertenancy" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::StarterTenancy.new(nil, nil, self), Form::Lettings::Questions::Tenancyother.new(nil, nil, self)]
  end
end
