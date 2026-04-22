---
nav_order: 2
parent: Testing
---

# Testing best practice

Note many old tests on CORE don't follow these guidelines. Feel free to bring them up to code.

## CollectionTimeHelper

Very useful class containing lots of date helper methods. Overuse these.

## Year-specific tests

The following guidelines should create tests that are:

- Unlikely to break between years
- Clearly marked when year specific
- Test up to date code wherever possible

Note that guidelines are directed for the point in time after a new form build has been completed.

If you're currently in new form build and writing new tests, imagine that it is currently post release of the form and follow the guidance from there. This is so we can be happy tests will not break on release day as well.

- If writing a test that doesn't need to be year specific, use `current_collection_start_year` or `current_collection_start_date`.

- If writing a test for the past, use `collection_start_date_for_year(year)`, and mark the test with metadata: `{ year: xx }`.

- If writing a test for the present & future, use `collection_start_date_for_year_or_later(year)`, and mark the test with metadata: `{ year: xx }`.

We only maintain tests for years that are currently editable in CORE (usually this and last collection year). If you see a file that contains tests for years older, consider updating or removing them.

## let syntax

You will see many tests using the `let` syntax. For instance `let(:collection_year) { 2026 }`. These are used to define variables specific to a given test. When the variable `collection_year` is called for the first time, the code inside the block will be evaluated.

They are useful for test specific logic. You can define a `before` block in an outer context, and use `let` blocks in an inner context to define the variables used in that before block. This allows for all arrange logic to be written once, drawing from variables defined later in a more specific context.

`let` blocks will not be evaluated till then run in a test. If you need them to be evaluated immediately (say, an inner context uses time travel), define a `let!` block.

## context

Contexts group related tests. They can also define `before` blocks that run before all tests in the context, and set up specific variables using `let`. With proper setup, a series of contexts can do all the arranging tests will need. This means the final test `it` blocks only need to act and assert.

## Example

A test suite may look like

```ruby
describe "class" do
  let(:dependent_object) { dependent_object(name: "test", year:) }

  context "#method" do
    before do
      # do some setup with dependent_object and year
    end

    context "in 2025", metadata: { year: 25 } do
      let(:year) { 2025 }

      it "works" do
        # act
        # assert
      end
    end

    context "in 2026 and later", metadata: { year: 26 } do
      let(:year) { collection_start_year_for_year_or_later(2026) }

      it "works also" do
        # act
        # assert
      end
    end
  end
end
```
