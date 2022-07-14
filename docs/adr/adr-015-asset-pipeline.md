---
parent: Architecture decisions
---

# 015: Serving Frontend Assets (JS, CSS, Images)

## Asset bundling (and JS transpilation)

Originally we were using [Webpacker](https://github.com/rails/webpacker) to bundle and serve our front end assets as this was the default in Rails 6. This was effectively a wrapper around webpack intended to abstract away it's complexity and provide sane Rails defaults. It combined both bundling and serving the assets.

However, since Rails 7, it's been deprecated by the Rails CORE team and it's javascript dependencies are no longer updated even for security fixes. As a result we decided we needed to move to one of the supported front end asset options.

The primary options considered were:


1. [Import maps](https://github.com/rails/importmap-rails) - Rails 7 default. Serve JS directly but do no transpiling so not suitable
2. [JSBundling](https://github.com/rails/jsbundling-rails) - Rails recommended
    - With [ESBuild](https://esbuild.github.io/) - fast and does some transpiling but [doesn't support ES5/IE11](https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/pull/203)
    - With [Rollup](https://www.rollupjs.org/guide/en/) - similar to ESBuild, node rather than Go based, doesn't have the big speed benefits
    - With [Webpack](https://webpack.js.org/) - rather than the old approach of using Webpacker as a opinionated wrapper around webpack, this approach uses webpack directly.
3. [Shakapacker](https://github.com/shakacode/shakapacker) - the "official" community maintained fork of Webpacker 6 RC. Requires upgrading current install since breaking changes happened between Webpacker 5 & 6
4. [Vite](https://vite-ruby.netlify.app/) - Webpack alternative

We need to consider that we had to support Internet Explorer 11/ES5 and that we have ES6 dependencies (Govuk frontend and Stimulus/Turbo).

This ruled out Import Maps as that approach doesn't support transpilation at all. It also ruled out using ESBuild as that supported some transpilation but not to the level we need.

Shakapacker is a continuation of the previous Webpacker approach. We explored seeing whether this would be the easiest path but Webpacker v5 -> v6 release candidate was a relatively significant breaking change and with the work required to update and this approach no longer being the favoured one upstream it seemed more worthwhile to make the bigger change to JSBundling directly.

Ultimately we moved to using JSBundling with Webpack and Babel. This exposes the webpack config directly in a way that is better documented upstream.

This change was made here: https://github.com/communitiesuk/submit-social-housing-lettings-and-sales-data/pull/392

We also use Webpack to bundle our CSS and Image assets.

## Asset Pipeline

JSBundling with Webpack handles the asset bundling part of what Webpacker used to do but still requires the asset pipeline to deliver it. The choices here are:

- [Sprockets](https://github.com/rails/sprockets-rails) - the original Rails asset pipeline and current default
- [Propshaft](https://github.com/rails/propshaft) - a more recent alternative that assumes most people will be using a node based JS bundler anyway and so can take a simpler approach than Sprockets by doing less

Given that our use case matches Propshaft quite closely and it's intended to replace Sprockets as the default for Rails at some point in the future we choose to use Propshaft.
