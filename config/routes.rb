Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "about", to: "about#index"
  get "/", to: "test#index"

  resources :case_logs do
    Form::QUESTIONS.keys.map do |question|
      get question.to_s, to: "case_logs##{question}"
      post question.to_s, to: "case_logs#next_question"
    end
  end
end
