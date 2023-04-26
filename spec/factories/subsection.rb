FactoryBot.define do
  factory :subsection, class: "Form::Subsection" do
    initialize_with { new(id, nil, nil) }
  end
end
