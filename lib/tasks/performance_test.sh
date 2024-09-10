cd performance_test
echo "Get token"
TOKEN=$(curl -c token_cookies.txt -s https://review.submit-social-housing-data.levellingup.gov.uk/2623/account/sign-in | grep '<meta name="csrf-token"' | sed -n 's/.*content="\([^"]*\)".*/\1/p')

echo "Logging in..."
echo $email
curl -L -o nul -c login_cookies.txt -b token_cookies.txt -X POST https://review.submit-social-housing-data.levellingup.gov.uk/2623/account/sign-in \
  -d "user[email]=$email" \
  -d "user[password]=$password" \
  -d "authenticity_token=$TOKEN"

COOKIES=$(awk '/_data_collector_session/ { print $6, $7 }' login_cookies.txt | tr ' ' '=')

echo "Running performance test..."
ab -n 50 -c 50 -C "$COOKIES" 'https://review.submit-social-housing-data.levellingup.gov.uk/2623/lettings-logs' > performance_test_results.txt
file="performance_test_results.txt"

failed_requests=$(grep "Failed requests:" "$file" | awk '{print $3}')
non_2xx_responses=$(grep "Non-2xx responses:" "$file" | awk '{print $3}')
time_per_request_all=$(grep "Time per request:" "$file" | awk 'NR==2{print $4}')
requests_per_second=$(grep "Requests per second:" "$file" | awk '{print $4}')


if [ "$failed_requests" -gt 0 ]; then
  echo "Performance test failed - $failed_requests failed requests"
  exit 1
fi

if [ "$non_2xx_responses" -ne 0 ] && [ -n "$non_2xx_responses" ]; then
  echo "Test failed: There were $non_2xx_responses non-2xx responses."
  exit 1
fi

if (( $(echo "$time_per_request_all > 45" | bc -l) )); then
  echo "Performance test failed - Time per request across all concurrent requests is more than 25 ms: $time_per_request_all ms"
  exit 1
fi

if (( $(echo "$requests_per_second < 20" | bc -l) )); then
  echo "Performance test failed - Requests per second is less than 20: $requests_per_second"
  exit 1
fi

echo "Test passed: No failed requests and no non-2xx responses."
exit 0
