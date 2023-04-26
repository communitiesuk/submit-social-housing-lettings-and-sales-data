FactoryBot.define do
  factory :subsection, class: "Form::Subsection" do
    id { "subsection_id" }
    initialize_with { new(id, nil, nil) }
    trait :with_questions do
      transient do
        question_ids { [] }

        after :build do |subsection, evaluator|
          subsection.pages = evaluator.question_ids.map { |id| build(:page, :with_question, question_id: id, subsection:) }
        end
      end
    end
  end
end
