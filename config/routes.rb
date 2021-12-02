Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: {
    passwords: "auth/passwords",
    sessions: "auth/sessions",
  }, path_names: { sign_in: "sign-in", sign_out: "sign-out" }

  devise_scope :user do
    get "confirmations/reset", to: "auth/passwords#reset_confirmation"
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)
  root to: "test#index"
  get "about", to: "about#index"

  resources :users do
    member do
      get "password/edit", to: "users#edit_password"
    end
  end

  resources :organisations do
    member do
      get "details", to: "organisations#details"
      get "users", to: "organisations#users"
      get "users/invite", to: "users/account#new"
    end
  end

  form_handler = FormHandler.instance
  form = form_handler.get_form("2021_2022")

  resources :case_logs, path: "/case-logs" do
    collection do
      post "bulk-upload", to: "bulk_upload#bulk_upload"
      get "bulk-upload", to: "bulk_upload#show"
    end

    member do
      post "form", to: "case_logs#submit_form"
    end

    form.pages.map do |page|
      get page.id.to_s.dasherize, to: "case_logs##{page.id}"
      get "#{page.id.to_s.dasherize}/soft-validations", to: "soft_validations#show" if page.has_soft_validations?
    end

    form.subsections.map do |subsection|
      get "#{subsection.id.to_s.dasherize}/check-answers", to: "case_logs#check_answers"
    end
  end
end
