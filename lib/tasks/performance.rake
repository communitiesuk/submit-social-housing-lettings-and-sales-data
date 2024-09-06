namespace :performance do
  desc "Export data XMLs for import into Central Data System (CDS)"
  task :run_ab, %i[email password] => :environment do |_task, args|
    email = Rails.root.join(args[:email])
    password = Rails.root.join(args[:password])

    system("echo install apache2-utils")
    system("apt-get update && apt-get install curl && apt-get install -y apache2-utils")
    system("echo get token")
    token = `curl -c token_cookies.txt -s https://review.submit-social-housing-data.levellingup.gov.uk/2621/account/sign-in | grep '<meta name="csrf-token"' | sed -n 's/.*content="\\([^"]*\\)".*/\\1/p'`

    system <<-BASH
    echo "Logging in..."
    curl -L -o nul -c login_cookies.txt -b token_cookies.txt -X POST https://review.submit-social-housing-data.levellingup.gov.uk/2621/account/sign-in \
      -d "user[email]=#{email}" \
      -d "user[password]=#{password}" \
      -d "authenticity_token=#{token}"

    # Extract cookies for use in the benchmark
    COOKIES=$(awk '/_data_collector_session/ { print $6, $7 }' login_cookies.txt | tr ' ' '=')

    # Run the Apache Benchmark
    ab -n 50 -c 50 -C "$COOKIES" 'https://review.submit-social-housing-data.levellingup.gov.uk/2621/lettings-logs'
    BASH
  end
end
