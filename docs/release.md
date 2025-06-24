---
nav_order: 6
---

# Releasing CORE code

Getting code released on core has the following steps.

## Gaining PO approval

Once a PR is dev approved, send the review app link to the PO for them to review, moving the ticket to PO review on Jira. Do not yet merge into main.

## Merging to main

Once the ticket is PO approved, the PR can be merged into main. This will deploy the branch to the staging environment.

## Creating a release

This is managed through GitHub releases

### Creating a draft release

In the GitHub releases section, create a new release. Release notes can be auto generated. All new commits on main since last release will be released.

Create a new version tag with an incremented version number.

### Getting release approval

Copy paste the release notes in the team slack channel and get tech lead approval.

### Publish

Publishing the release will deploy to prod.

The release action copies the current staging images to prod. Ensure that when publishing the release, the last **staging deployment pipeline** has completed successfully.
Else, changes will not be deployed as expected.
