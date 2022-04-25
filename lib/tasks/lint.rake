desc "Run Rubocop"
task rubocop: :environment do
  sh "bundle exec rubocop"
end

desc "Run ERB Lint"
task erblint: :environment do
  sh "bundle exec erblint --lint-all"
end

desc "Run Stylelint"
task stylelint: :environment do
  sh "yarn stylelint app/frontend/styles"
end

desc "Run all the linters"
task lint: %i[rubocop erblint stylelint]
