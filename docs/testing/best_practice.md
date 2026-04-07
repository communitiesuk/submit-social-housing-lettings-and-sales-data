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
