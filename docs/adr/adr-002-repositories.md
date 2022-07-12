---
parent: Architecture decisions
---

# 002: Repositories

There will be two git repositories for this project.

1. [Infrastructure](https://github.com/communitiesuk/mhclg-data-collection-beta-infrastructure)
2. Web application (this repository)

This will enable infrastructure and application changes to be worked on somewhat independently more easily as well as avoiding needing to run infrastructure pipeline actions for every application change, given that application changes are likely to be significantly more frequent.

It also reduces complexity for people working on just one or the other.
