Rails.application.routes.draw do
  devise_for :admin_users, {
    path: :admin,
    controllers: {
      sessions: "auth/sessions",
      passwords: "auth/passwords",
      unlocks: "active_admin/devise/unlocks",
      registrations: "active_admin/devise/registrations",
      confirmations: "active_admin/devise/confirmations",
      two_factor_authentication: "auth/two_factor_authentication",
    },
    path_names: { sign_in: "sign-in", sign_out: "sign-out", two_factor_authentication: "two-factor-authentication" },
    sign_out_via: %i[delete get],
  }

  devise_scope :admin_user do
    get "admin/two-factor-authentication/resend", to: "auth/two_factor_authentication#show_resend"
  end

  devise_for :users, controllers: {
    passwords: "auth/passwords",
    sessions: "auth/sessions",
  }, path_names: { sign_in: "sign-in", sign_out: "sign-out" }

  devise_scope :user do
    get "confirmations/reset", to: "auth/passwords#reset_confirmation"
  end

  get "/health", to: ->(_) { [204, {}, [nil]] }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)

  root to: "start#index"

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

  resources :case_logs, path: "/logs" do
    collection do
      post "bulk-upload", to: "bulk_upload#bulk_upload"
      get "bulk-upload", to: "bulk_upload#show"
    end

    member do
      post "form", to: "form#submit_form"
    end

    FormHandler.instance.forms.each do |_key, form|
      form.pages.map do |page|
        get page.id.to_s.dasherize, to: "form##{page.id}"
      end

      form.subsections.map do |subsection|
        get "#{subsection.id.to_s.dasherize}/check-answers", to: "form#check_answers"
      end
    end
  end

  scope via: :all do
    match "/404", to: "errors#not_found"
    match "/429", to: "errors#too_many_requests", status: 429
    match "/422", to: "errors#unprocessable_entity"
    match "/500", to: "errors#internal_server_error"
  end
end
