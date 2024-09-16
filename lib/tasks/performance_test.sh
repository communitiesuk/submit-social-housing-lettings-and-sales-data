cd performance_test

# Lettings logs page
echo "Get token"
TOKEN=$(curl -c token_cookies.txt -s https://staging.submit-social-housing-data.levellingup.gov.uk/account/sign-in | grep '<meta name="csrf-token"' | sed -n 's/.*content="\([^"]*\)".*/\1/p')

echo "Logging in..."
echo $email
curl -L -o nul -c login_cookies.txt -b token_cookies.txt -X POST https://staging.submit-social-housing-data.levellingup.gov.uk/account/sign-in \
  -d "user[email]=$email" \
  -d "user[password]=$password" \
  -d "authenticity_token=$TOKEN"

COOKIES=$(awk '/_data_collector_session/ { print $6, $7 }' login_cookies.txt | tr ' ' '=')

echo "Running lettings logs page performance test..."
ab -n 50 -c 50 -l -C "$COOKIES" 'https://staging.submit-social-housing-data.levellingup.gov.uk/lettings-logs?years[]=2024&status[]=completed' > performance_lettings_test_results.txt
file="performance_lettings_test_results.txt"

failed_requests=$(grep "Failed requests:" "$file" | awk '{print $3}')
non_2xx_responses=$(grep "Non-2xx responses:" "$file" | awk '{print $3}')
time_per_request_all=$(grep "Time per request:" "$file" | awk 'NR==2{print $4}')
requests_per_second=$(grep "Requests per second:" "$file" | awk '{print $4}')


if [ "$failed_requests" -gt 0 ]; then
  echo "Lettings logs: Performance test failed - $failed_requests failed requests"
  exit 1
fi

if [ "$non_2xx_responses" -ne 0 ] && [ -n "$non_2xx_responses" ]; then
  echo "Lettings logs: Performance test failed: There were $non_2xx_responses non-2xx responses."
  exit 1
fi

if (( $(echo "$time_per_request_all > 250" | bc -l) )); then
  echo "Lettings logs: Performance test failed - Time per request across all concurrent requests is more than 250 ms: $time_per_request_all ms"
  exit 1
fi

if (( $(echo "$requests_per_second < 5" | bc -l) )); then
  echo "Lettings logs: Performance test failed - Requests per second is less than 5: $requests_per_second"
  exit 1
fi

echo "Lettings logs page test passed: No failed requests and no non-2xx responses."


# Sales logs page
echo "Running sales logs page performance test..."
ab -n 50 -c 50 -l -C "$COOKIES" 'https://staging.submit-social-housing-data.levellingup.gov.uk/sales-logs?years[]=2024&status[]=completed' > performance_sales_test_results.txt
file="performance_sales_test_results.txt"

failed_requests=$(grep "Failed requests:" "$file" | awk '{print $3}')
non_2xx_responses=$(grep "Non-2xx responses:" "$file" | awk '{print $3}')
time_per_request_all=$(grep "Time per request:" "$file" | awk 'NR==2{print $4}')
requests_per_second=$(grep "Requests per second:" "$file" | awk '{print $4}')


if [ "$failed_requests" -gt 0 ]; then
  echo "Sales logs: Performance test failed - $failed_requests failed requests"
  exit 1
fi

if [ "$non_2xx_responses" -ne 0 ] && [ -n "$non_2xx_responses" ]; then
  echo "Sales logs: Performance test failed: There were $non_2xx_responses non-2xx responses."
  exit 1
fi

if (( $(echo "$time_per_request_all > 250" | bc -l) )); then
  echo "Sales logs: Performance test failed - Time per request across all concurrent requests is more than 250 ms: $time_per_request_all ms"
  exit 1
fi

if (( $(echo "$requests_per_second < 5" | bc -l) )); then
  echo "Sales logs: Performance test failed - Requests per second is less than 5: $requests_per_second"
  exit 1
fi

echo "Sales logs page test passed: No failed requests and no non-2xx responses."


# Post data to a log test
page_content=$(curl -b login_cookies.txt -s 'https://staging.submit-social-housing-data.levellingup.gov.uk/lettings-logs?years[]=2024&status[]=completed')
completed_log_link=$(echo "$page_content" | sed -n 's/.*<a class="govuk-link" href="\([^"]*lettings-logs[^"]*\)".*/\1/p' | head -n 1)
echo "testing post to $completed_log_link"

TOKEN=$(curl -L -b login_cookies.txt -c login_cookies.txt https://staging.submit-social-housing-data.levellingup.gov.uk$completed_log_link/tenant-code | grep '<meta name="csrf-token"' | sed -n 's/.*content="\([^"]*\)".*/\1/p')

COOKIES=$(awk '/_data_collector_session/ { print $6, $7 }' login_cookies.txt | tr ' ' '=')

echo "lettings_log[tenancycode]=performance_test_tenancy_code&lettings_log[page]=tenant_code&authenticity_token=$TOKEN" > post_data.txt

ab -n 50 -c 50 -l -T application/x-www-form-urlencoded \
-H "X-CSRF-Token: $TOKEN" \
-C "$COOKIES" \
-p post_data.txt \
"https://staging.submit-social-housing-data.levellingup.gov.uk$completed_log_link/tenant-code" > performance_post_test_results.txt

file="performance_post_test_results.txt"
failed_requests=$(grep "Failed requests:" "$file" | awk '{print $3}')
time_per_request_all=$(grep "Time per request:" "$file" | awk 'NR==2{print $4}')
requests_per_second=$(grep "Requests per second:" "$file" | awk '{print $4}')


if [ "$failed_requests" -gt 0 ]; then
  echo "Update logs: Performance test failed - $failed_requests failed requests"
  exit 1
fi

if (( $(echo "$time_per_request_all > 500" | bc -l) )); then
  echo "Update logs: Performance test failed - Time per request across all concurrent requests is more than 500 ms: $time_per_request_all ms"
  exit 1
fi

if (( $(echo "$requests_per_second < 3" | bc -l) )); then
  echo "Update logs: Performance test failed - Requests per second is less than 5: $requests_per_second"
  exit 1
fi

echo "Update logs test passed: No failed requests and request times as expected."

echo "All tests passed"
exit 0
