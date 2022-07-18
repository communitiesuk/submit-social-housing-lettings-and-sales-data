---
parent: Architecture decisions
---

# 015: Hotwire & Internet Explorer

Initially we intended to use Hotwire (Stimulus and Turbo). Stimulus as our "minimal javascript framework", Turbo to provide an "SPA-like" experience. However, despite now being deprecated by Microsoft, a significant proportion of our users are still using Internet Explorer 10/11 to access the service (~30% based on 2021 server logs) and so we needed to support Internet Explorer >= 10 also for the time being. This presented a problem as neither Stimulus nor Turbo support Internet Explorer and upstream have indicated there is [no interest in adding support](https://github.com/hotwired/hotwire-rails/issues/32).

To address this we first attempted to transpile the Stimulus and Turbo libraries from ES6 down to ES5 with Babel and add any required polyfills.

For **Stimulus** we were able to do this and are continuing to use it. This is achieved by:

- Adding the [@Stimulus/Polyfills](https://www.npmjs.com/package/@stimulus/polyfills) package to our [package.json](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/blob/main/package.json#L12)
- Adding the StimulusJS NPM package path to our [webpack config](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/blob/main/webpack.config.js#L23) rules to be transpiled
- Adding the required Babel plugins to our [Babel config](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/blob/main/babel.config.js#L34)

For **Turbo** the same approach was attempted but proved [unsuccessful](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/pull/430). As a result we decided to [remove Turbo](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/pull/406) until we can drop support for Internet Explorer. This does have a perceptible impact on UX/speed but provides the most browser compatibility. 
