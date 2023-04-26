FactoryBot.define do
  factory :page, class: "Form::Page" do
    initialize_with { new(id, nil, nil) }
  end
end
