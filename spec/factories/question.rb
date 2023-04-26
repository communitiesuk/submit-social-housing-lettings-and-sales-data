FactoryBot.define do
  factory :question, class: "Form::Question" do
    initialize_with { new(id, nil, nil) }
    type { "text" }
  end
end
