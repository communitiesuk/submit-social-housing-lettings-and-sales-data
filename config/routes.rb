Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "about", to: "about#index"
  get "/", to: "test#index"

  post '/case_logs/:id', to: "case_logs#next_page"

  form = Form.new(2021, 2022)
  resources :case_logs do
    form.all_pages.keys.map do |page|
      get page.to_s, to: "case_logs##{page}"
      form.all_subsections.keys.map do |subsection|
        get "#{subsection}/check_answers", to: "case_logs#check_answers"
      end
    end
  end
end
