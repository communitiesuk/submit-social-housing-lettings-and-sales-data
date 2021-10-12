Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "about", to: "about#index"
  get "/", to: "test#index"

  post "/case_logs/:id", to: "case_logs#submit_form"

  form = ENV["RAILS_ENV"] == "test" ? Form.new("test", "form") : Form.new(2021, 2022)
  resources :case_logs do
    form.all_pages.keys.map do |page|
      get page.to_s, to: "case_logs##{page}"
    end
    form.all_subsections.keys.map do |subsection|
      get "#{subsection}/check_answers", to: "case_logs#check_answers"
    end
  end
end
