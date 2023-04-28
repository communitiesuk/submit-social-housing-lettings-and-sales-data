FactoryBot.define do
  factory :section, class: "Form::Section" do
    id { "section_id" }
    initialize_with { new(id, nil, nil) }
    trait :with_questions do
      transient do
        question_ids { nil }
        questions { nil }
      end

      after :build do |section, evaluator|
        section.subsections = [build(:subsection, :with_questions, question_ids: evaluator.question_ids, questions: evaluator.questions, section:)]
      end
    end
  end
end
