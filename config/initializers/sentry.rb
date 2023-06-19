Sentry.init do |config|
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.enabled_environments = %w[production staging review]

  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]
    op = transaction_context[:op]
    transaction_name = transaction_context[:name]

    case op
    when /request/
      case transaction_name
      when /health/
        0.0 # ignore healthcheck requests
      else
        0.01
      end
    when /sidekiq/
      0.001
    else
      0.0 # We don't care about performance of other things
    end
  end
end
