desc "Run Rubocop"
task rubocop: :environment do
  sh "bundle exec rubocop"
end

desc "Run Rubocop Autocorrect"
task rubocop_autocorrect: :environment do
  sh "bundle exec rubocop -A"
end

desc "Run ERB Lint"
task erblint: :environment do
  sh "bundle exec erb_lint --lint-all"
end

desc "Run Standard"
task standard: :environment do
  sh "yarn standard"
end

desc "Run Stylelint"
task stylelint: :environment do
  sh "yarn stylelint app/frontend/styles"
end

desc "Run Prettier"
task prettier: :environment do
  sh "yarn prettier . --check"
end

desc "Run all the linters"
task lint: %i[rubocop erblint standard stylelint prettier]
