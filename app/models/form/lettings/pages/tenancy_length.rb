class Form::Lettings::Pages::TenancyLength < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_length"
    @header = ""
    @depends_on = [{ "tenancy" => 4 }, { "tenancy" => 6 }, { "tenancy" => 3 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Tenancylength.new(nil, nil, self)]
  end
end
