FactoryBot.define do
  factory :section, class: "Form::Section" do
    initialize_with { new(id, nil, nil) }
  end
end
