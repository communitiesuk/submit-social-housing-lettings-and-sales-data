# Question: Which OS product can we use to do our address to UPRN lookup?

- #UPRN: to check if provided UPRN exists

API DOCS: https://osdatahub.os.uk/docs/places/technicalSpecification

- #Find: freetext to search results containing UPRNs
https://api.os.uk/search/places/v1/find?query=Ordnance%20Survey%2C%20Adanac%20Drive%2C%20SO16&key=


# Question: Can we do API lookups? Are there any limitations on the product (API requests etc.)

- Can't see any sort of limitation for our account: "As a member of the PSGA you are entitled to free Public Sector data transactions"
https://osdatahub.os.uk/dashboard



# Additional QQ and notes:
- when searching UPRN from address there are usually multiple results and match accuracy isn't provided. Do we want users to pick the matching address or should we just pick the first match?
- could not find a free OS ruby client for the API that I would recommend using. Best option is this but seems to be relying on a private repository https://github.com/DEFRA/defra-ruby-address/
- Auth strategy, there's 3 of them HTTP Header / Query String / OAuth2.


Flows that need to be handled:
- UPRN check:
  - API is down / not responding
  - UPRN is invalid
  - UPRN is valid
- UPRN retrieval via address:
  - API is down / not responding
  - Address is valid but no UPRN found
  - Address is valid and UPRN found
  - Address is valid but multiple UPRNs found
  - Address is not found and multiple UPRNs found
