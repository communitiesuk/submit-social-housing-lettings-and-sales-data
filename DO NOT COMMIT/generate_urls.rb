def generate_urls
  log_ids = %w[
    56f1de1c-fb89-4698-895e-31da3da21357
    312e4268-0fb5-4c29-b643-1366bdbceb09
    49499139-1e4a-405a-b28b-389469de7744
  ]

  types = %w[
    CORE-AR-GN
    CORE-AR-SH
    CORE-IR-GN
    CORE-IR-SH
    CORE-SR-GN
    CORE-SR-SH
    CORE-Sales
  ]

  years = [2021, 2022, 2023]

  years.each do |year|
    log_ids.each do |log_id|
      types.each do |log_type|
        url = "https://core.communities.gov.uk/DataCollection/logs/#{year}-#{log_type}/#{log_id}.html"
        puts url
      end
    end
  end
end

generate_urls
