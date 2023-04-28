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
        if evaluator.questions
          subsection.pages = evaluator.questions.map { |question| build(:page, :with_question, question:, subsection:) }
        else
          subsection.pages = evaluator.question_ids.map { |id| build(:page, :with_question, question_id: id, subsection:) }
        end
      end
    end
  end
end
