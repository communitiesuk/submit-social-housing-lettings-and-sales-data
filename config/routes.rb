Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)
  root to: "test#index"
  get "about", to: "about#index"

  post "/case_logs/:id", to: "case_logs#submit_form", constraints: { id: /\d.+/ }

  form_handler = FormHandler.instance
  form = form_handler.get_form("2021_2022")

  resources :case_logs do
    collection do
      post "/bulk_uploads", to: "bulk_upload#bulk_upload"
      get "/bulk_uploads", to: "bulk_upload#show"
    end

    form.all_pages.keys.map do |page|
      get page.to_s, to: "case_logs##{page}"
      get "#{page}/soft_validations", to: "soft_validations#show" if form.soft_validations_for_page(page)
    end

    form.all_subsections.keys.map do |subsection|
      get "#{subsection}/check_answers", to: "case_logs#check_answers"
    end
  end
end
