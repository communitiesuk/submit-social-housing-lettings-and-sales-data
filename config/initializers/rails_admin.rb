RailsAdmin.config do |config|
  config.asset_source = :webpack

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.authorize_with do
    redirect_to main_app.root_path unless current_user&.support?
  end
  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  config.show_gravatar = false
  config.included_models = %w[LogValidation CsvVariableDefinition]

  config.model "LogValidation" do
    label "Log Validation"
  end

  config.model "CsvVariableDefinition" do
    label "CSV Variable Definition"
    edit do
      exclude_fields :last_accessed
      field :log_type do
        help "Required. Specify the type of log associated with this variable: 'lettings' or 'sales'."
      end
      field :year do
        help "Required. Specify the year this definition should be available from. This definition will be used in subsequent years unless superseded by a newer definition."
      end
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
