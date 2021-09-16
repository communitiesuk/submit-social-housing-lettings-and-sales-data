Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "about", to: "about#index"
  get "/", to: "test#index"

  resources :case_logs do
    get "form", to: "case_logs#next_question"
    post "form", to: "case_logs#next_question"
    Form::QUESTIONS.keys.map do |question|
      get "#{question}", to: "case_logs##{question}"
    end
  end
end
