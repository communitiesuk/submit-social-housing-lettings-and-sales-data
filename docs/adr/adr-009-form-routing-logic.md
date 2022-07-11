---
parent: Architecture decisions
---

# 009: Form routing logic

There are 2 ways you can think about form (page) routing logic:

1. Based on the answer you give to a page you are navigated to some point in the form, i.e. a ‘jump to’
2. Each question is considered sequentially and independently and we evaluate whether it should be shown or not

Our Form Definition DSL takes the second approach. This has a couple of advantages:

- It makes the check answers pattern easier to code as you can ask each page directly: “Have the conditions for you to be shown been met?”, with approach 1, you would effectively have to traverse the full route branch to see if a particular page was shown for each page/question which adds complexity.

- It makes it easier to look at the JSON and see at a glance what conditions will show or hide a page, which is closer to how the business logic is discussed and is easier to reason about.
