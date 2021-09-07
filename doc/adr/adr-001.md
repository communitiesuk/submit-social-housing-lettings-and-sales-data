### ADR - 001: Initial Architecture Decisions

##### Application Framework

Ruby on Rails
- Well established and commonly used within MHCLG and gov.uk in general
- Good ecosystem for common web app tasks, quick productivity
- Matches team skill set
- Analysis/RAP pipelines will sit in the DAP platform and not this application directly so optimising for web framework tasks makes sense.

Testing
 - Rspec for unit testing
 - Capybara or Cypress-Rails for front end testing
 - TDD or ATDD approach
 - No specific code coverage target or deploy gate as we feel this leads to arbitrary metric chasing and is counter-productive

Front end
- In the same app codebase
- ERB templates

Code Style & Linting
- Gov.uk Rubocop for Ruby style
- .editorconfig for whitespace, newlines etc


<br />

#### Ways of Working

- Flexible approach to branching. Generally Trunk based CI (every TDD round results in a commit and push to master) when pairing, branches and PR when doing solo or more exploratory work.
- Github actions for automated test, build, deploy pipeline
- Github actions should run Rubocop, RSpec, Front end tests, docker build and deploy
- Encourage pairing
