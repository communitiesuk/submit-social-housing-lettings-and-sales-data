Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: {
    passwords: "users/passwords",
    sessions: "users/sessions",
    registrations: "users/registrations"
  }, path_names: { sign_in: 'sign-in', sign_out: 'sign-out', sign_up: 'invite' }

  devise_scope :user do
    get "user", to: "users/account#index"
    get "users", to: "users/account#index"
    get "users/account", to: "users/account#index"
    get "confirmations/reset", to: "users/passwords#reset_confirmation"
    get "users/account/personal_details", to: "users/account#edit"
    patch "details", to: "users/account#update", as: "account_update"
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)
  root to: "test#index"
  get "about", to: "about#index"

  form_handler = FormHandler.instance
  form = form_handler.get_form("2021_2022")

  resources :organisations do
    member do
      get "details", to: "organisations#show"
      get "users", to: "organisations#users"
    end
  end

  resources :case_logs, path: "/case-logs" do
    collection do
      post "/bulk-upload", to: "bulk_upload#bulk_upload"
      get "/bulk-upload", to: "bulk_upload#show"
    end

    member do
      post "/form", to: "case_logs#submit_form"
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
