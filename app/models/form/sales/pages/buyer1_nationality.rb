class Form::Sales::Pages::Buyer1Nationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_nationality"
    @depends_on = [
      {
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= if form.start_year_2024_or_later?
                     [
                       Form::Sales::Questions::NationalityAllGroup.new("nationality_all_group", nil, self, 1),
                       Form::Sales::Questions::NationalityAll.new("nationality_all", nil, self, 1),
                     ]
                   else
                     [Form::Sales::Questions::Buyer1Nationality.new(nil, nil, self)]
                   end
  end
end
