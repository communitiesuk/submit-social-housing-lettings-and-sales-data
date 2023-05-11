FactoryBot.define do
  factory :subsection, class: "Form::Subsection" do
    id { "subsection_id" }
    initialize_with { new(id, nil, nil) }
    trait :with_questions do
      transient do
        question_ids { nil }
        questions { nil }
      end

      after :build do |subsection, evaluator|
        subsection.pages = if evaluator.questions
                             evaluator.questions.map { |question| build(:page, :with_question, question:, subsection:) }
                           else
                             evaluator.question_ids.map { |question_id| build(:page, :with_question, question_id:, subsection:) }
                           end
      end
    end
  end
end
