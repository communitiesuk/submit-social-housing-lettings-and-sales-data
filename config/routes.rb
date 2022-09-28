# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users, {
    path: :account,
    controllers: {
      confirmations: "auth/confirmations",
      passwords: "auth/passwords",
      sessions: "auth/sessions",
      two_factor_authentication: "auth/two_factor_authentication",
    },
    path_names: {
      sign_in: "sign-in",
      sign_out: "sign-out",
      two_factor_authentication: "two-factor-authentication",
      two_factor_authentication_resend_code: "resend-code",
    },
    sign_out_via: %i[get],
  }

  devise_scope :user do
    get "account/password/reset-confirmation", to: "auth/passwords#reset_confirmation"
    get "account/two-factor-authentication/resend", to: "auth/two_factor_authentication#show_resend", as: "user_two_factor_authentication_resend"
    put "account", to: "users#update"
  end

  get "/health", to: ->(_) { [204, {}, [nil]] }

  root to: "start#index"

  get "/logs", to: redirect("/lettings-logs")

  FormHandler.instance.forms.each do |_key, form|
    form.pages.map do |page|
      get "/lettings-log/new/#{page.id.to_s.dasherize}", to: "form#show_page"
      get "/sales-log/new/#{page.id.to_s.dasherize}", to: "form#show_page"
    end
  end

  get "/accessibility-statement", to: "content#accessibility_statement"
  get "/privacy-notice", to: "content#privacy_notice"
  get "/data-sharing-agreement", to: "content#data_sharing_agreement"

  resource :account, only: %i[show edit], controller: "users" do
    get "edit/password", to: "users#edit_password"
  end

  resources :schemes do
    get "primary-client-group", to: "schemes#primary_client_group"
    get "confirm-secondary-client-group", to: "schemes#confirm_secondary_client_group"
    get "secondary-client-group", to: "schemes#secondary_client_group"
    get "support", to: "schemes#support"
    get "details", to: "schemes#details"
    get "check-answers", to: "schemes#check_answers"
    get "edit-name", to: "schemes#edit_name"
    get "support-services-provider", to: "schemes#support_services_provider"

    member do
      resources :locations do
        get "edit-name", to: "locations#edit_name"
        get "edit", to: "locations#edit"
      end
    end
  end

  resources :users do
    get "edit-dpo", to: "users#dpo"
    get "edit-key-contact", to: "users#key_contact"

    member do
      get "deactivate", to: "users#deactivate"
      get "reactivate", to: "users#reactivate"
    end
  end

  resources :organisations do
    member do
      get "details", to: "organisations#details"
      get "users", to: "organisations#users"
      get "users/invite", to: "users/account#new"
      get "lettings-logs", to: "organisations#lettings_logs"
      get "sales-logs", to: "organisations#sales_logs"
      get "logs/csv-download", to: "organisations#download_csv"
      post "logs/email-csv", to: "organisations#email_csv"
      get "logs/csv-confirmation", to: "lettings_logs#csv_confirmation"
      get "schemes", to: "organisations#schemes"
    end
  end

  resources :lettings_logs, path: "/lettings-logs" do
    collection do
      get "create-new-log", to: "lettings_logs#create"
      get "new-log", to: "lettings_logs#show"
      post "new-form", to: "form#submit_form"
      post "bulk-upload", to: "bulk_upload#bulk_upload"
      get "bulk-upload", to: "bulk_upload#show"
      get "csv-download", to: "lettings_logs#download_csv"
      post "email-csv", to: "lettings_logs#email_csv"
      get "csv-confirmation", to: "lettings_logs#csv_confirmation"
      FormHandler.instance.forms.each do |_key, form|
        form.pages.map do |page|
          get "new/#{page.id.to_s.dasherize}", to: "form#show_new_page"
        end
      end
    end

    member do
      post "form", to: "form#submit_form"
      get "review", to: "form#review"
    end

    FormHandler.instance.lettings_forms.each do |_key, form|
      form.pages.map do |page|
        get page.id.to_s.dasherize, to: "form#show_page"
      end

      form.subsections.map do |subsection|
        get "#{subsection.id.to_s.dasherize}/check-answers", to: "form#check_answers"
      end
    end
  end

  resources :sales_logs, path: "/sales-logs" do
    collection do
      get "create-new-log", to: "sales_logs#create"
      get "new-log", to: "sales_logs#show"
    end

    FormHandler.instance.sales_forms.each do |_key, form|
      form.pages.map do |page|
        get page.id.to_s.dasherize, to: "form#show_page"
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
