class Form::Sales::Pages::SharedOwnershipDepositValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "shared_ownership_deposit_invalid?" => true,
      },
    ]
    @informative_text = {}
    @title_text = {
      "translation" => "soft_validations.shared_ownership_deposit.title_text",
      "arguments" => [
        {
          "key" => "expected_shared_ownership_deposit_value",
          "label" => false,
          "i18n_template" => "expected_shared_ownership_deposit_value",
          "money" => true,
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SharedOwnershipDepositValueCheck.new(nil, nil, self),
    ]
  end
end
