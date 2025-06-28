---
nav_order: 6
---

# Releasing CORE code

Getting code released on core has the following steps.

## Releasing to staging

Merging a branch to `main` will trigger the staging deployment pipeline.

## Releasing to prod

This is managed through GitHub releases

### Creating a draft release

In the GitHub releases section, create a new release. Release notes can be auto generated. All new commits on main since last release will be released.

Create a new version tag with an incremented version number.

Be sure to save the release as a draft until it is ready to be deployed.

### Publish

Publishing the release will deploy to prod.

The release action copies the current staging images to prod. Ensure that when publishing the release, the last **staging deployment pipeline** has completed successfully.
Else, changes will not be deployed as expected.
