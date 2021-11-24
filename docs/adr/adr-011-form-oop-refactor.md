### ADR - 011: Splitting the form parsing into objects

Initially a single "Form" class handled the parsing of the form definition JSON as well as a lot of the logic around what different sections meant. This works fine but led to a lot of places in code where we're passing around arguments to determine whether a page or section should or shouldn't do something rather than being able to ask it directly. Refactoring this into smaller form domain object classes has several benefits:

- It's easier to compare the form definition JSON to the code classes and reason about what fields can be passed and what effect they'll have
- It moves business logic out of the helpers and keeps them to just dealing with display logic
- It makes it easier to unit test form functionality, and group that into smaller chunks
- It allows for less passing of arguments. e.g. `page.routed_to?(case_log)` vs `form.was_page_routed_to?(page, case_log)`

This abstraction is likely still not the best (the form vs case log split) but this seems like an improvement that can be iterated on. 
