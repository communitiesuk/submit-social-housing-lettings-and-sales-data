FactoryBot.define do
  factory :page, class: "Form::Page" do
    id { "page_id" }
    initialize_with { new(id, nil, nil) }
    trait :with_question do
      transient do
        question_id { nil }
        question { nil }
      end

      after :build do |page, evaluator|
        if q = evaluator.question
          q.page = page
          page.questions = [q]
        elsif
          page.questions = [build(:question, id: evaluator.question_id, page:)]
        end
      end
    end
  end
end
