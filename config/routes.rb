# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  mount_sidekiq = -> { mount Sidekiq::Web => "/sidekiq" }
  authenticate(:user, :support?.to_proc, &mount_sidekiq)

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
  resource :cookies, only: %i[show update]

  root to: "start#index"

  get "/logs", to: redirect("/lettings-logs")
  get "/accessibility-statement", to: "content#accessibility_statement"
  get "/privacy-notice", to: "content#privacy_notice"
  get "/data-sharing-agreement", to: "content#data_sharing_agreement"

  get "/download-23-24-lettings-form", to: "start#download_23_24_lettings_form"
  get "/download-23-24-lettings-bulk-upload-template", to: "start#download_23_24_lettings_bulk_upload_template"
  get "/download-23-24-lettings-bulk-upload-legacy-template", to: "start#download_23_24_lettings_bulk_upload_legacy_template"
  get "/download-23-24-lettings-bulk-upload-specification", to: "start#download_23_24_lettings_bulk_upload_specification"

  get "/download-22-23-lettings-bulk-upload-template", to: "start#download_22_23_lettings_bulk_upload_template"
  get "/download-22-23-lettings-bulk-upload-specification", to: "start#download_22_23_lettings_bulk_upload_specification"

  get "/download-23-24-sales-form", to: "start#download_23_24_sales_form"
  get "/download-22-23-sales-form", to: "start#download_22_23_sales_form"

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
    get "new-deactivation", to: "schemes#new_deactivation"
    get "deactivate-confirm", to: "schemes#deactivate_confirm"
    get "reactivate", to: "schemes#reactivate"
    get "new-reactivation", to: "schemes#new_reactivation"
    patch "new-deactivation", to: "schemes#new_deactivation"
    patch "deactivate", to: "schemes#deactivate"
    patch "reactivate", to: "schemes#reactivate"

    resources :locations do
      post "locations", to: "locations#create"
      get "new-deactivation", to: "locations#new_deactivation"
      get "deactivate-confirm", to: "locations#deactivate_confirm"
      get "reactivate", to: "locations#reactivate"
      get "new-reactivation", to: "locations#new_reactivation"
      get "postcode", to: "locations#postcode"
      patch "postcode", to: "locations#update_postcode"
      get "local-authority", to: "locations#local_authority"
      patch "local-authority", to: "locations#update_local_authority"
      get "name", to: "locations#name"
      patch "name", to: "locations#update_name"
      get "units", to: "locations#units"
      patch "units", to: "locations#update_units"
      get "type-of-unit", to: "locations#type_of_unit"
      patch "type-of-unit", to: "locations#update_type_of_unit"
      get "mobility-standards", to: "locations#mobility_standards"
      patch "mobility-standards", to: "locations#update_mobility_standards"
      get "availability", to: "locations#availability"
      patch "availability", to: "locations#update_availability"
      get "check-answers", to: "locations#check_answers"
      patch "confirm", to: "locations#confirm"
      patch "new-deactivation", to: "locations#new_deactivation"
      patch "deactivate", to: "locations#deactivate"
      patch "reactivate", to: "locations#reactivate"
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
      get "stock-owners", to: "organisation_relationships#stock_owners"
      get "stock-owners/add", to: "organisation_relationships#add_stock_owner"
      get "stock-owners/remove", to: "organisation_relationships#remove_stock_owner"
      post "stock-owners", to: "organisation_relationships#create_stock_owner"
      delete "stock-owners", to: "organisation_relationships#delete_stock_owner"
      get "managing-agents", to: "organisation_relationships#managing_agents"
      get "managing-agents/add", to: "organisation_relationships#add_managing_agent"
      get "managing-agents/remove", to: "organisation_relationships#remove_managing_agent"
      post "managing-agents", to: "organisation_relationships#create_managing_agent"
      delete "managing-agents", to: "organisation_relationships#delete_managing_agent"
      get "merge-request", to: "organisations#merge_request"
    end
  end

  resources :merge_requests, path: "/merge-request" do
    member do
      get "organisations"
      patch "organisations", to: "merge_requests#update_organisations"
      get "organisations/remove", to: "merge_requests#remove_merging_organisation"
      get "absorbing-organisation"
    end
  end

  resources :lettings_logs, path: "/lettings-logs" do
    collection do
      post "bulk-upload", to: "bulk_upload#bulk_upload"
      get "bulk-upload", to: "bulk_upload#show"

      get "csv-download", to: "lettings_logs#download_csv"
      post "email-csv", to: "lettings_logs#email_csv"
      get "csv-confirmation", to: "lettings_logs#csv_confirmation"

      resources :bulk_upload_lettings_logs, path: "bulk-upload-logs", only: %i[show update] do
        collection do
          get :start
        end
      end

      resources :bulk_upload_lettings_results, path: "bulk-upload-results", only: [:show] do
        member do
          get :resume
          get :summary
        end
      end

      resources :bulk_upload_lettings_resume, path: "bulk-upload-resume", only: %i[show update] do
        member do
          get :start

          get "*page", to: "bulk_upload_lettings_resume#show", as: "page"
          patch "*page", to: "bulk_upload_lettings_resume#update"
        end
      end

      get "update-logs", to: "lettings_logs#update_logs"
    end

    member do
      post "form", to: "form#submit_form"
      get "review", to: "form#review"
    end

    FormHandler.instance.lettings_forms.each do |_key, form|
      form.pages.map do |page|
        get page.id.to_s.dasherize, to: "form#show_page"
        post page.id.to_s.dasherize, to: "form#submit_form"
      end

      form.subsections.map do |subsection|
        get "#{subsection.id.to_s.dasherize}/check-answers", to: "form#check_answers"
      end
    end
  end

  resources :sales_logs, path: "/sales-logs" do
    collection do
      resources :bulk_upload_sales_logs, path: "bulk-upload-logs" do
        collection do
          get :start
        end
      end

      resources :bulk_upload_sales_results, path: "bulk-upload-results", only: [:show] do
        member do
          get :resume
          get :summary
        end
      end
    end

    member do
      get "review", to: "form#review"
    end

    FormHandler.instance.sales_forms.each do |_key, form|
      form.pages.map do |page|
        get page.id.to_s.dasherize, to: "form#show_page"
        post page.id.to_s.dasherize, to: "form#submit_form"
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
