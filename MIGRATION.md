# Migration Guide

## v12.0.0

Version 12 of orb-tools enhances the contributor experience by removing the roadblock of needing to publish a development orb for testing. Orbs are now _injected_ dynamically into the pipeline, allowing for orb testing without the need for access to a publishing token.

_Note: If you are upgrading from 11.x to 12.x proceed here. If you are upgrading from an earlier version, please see the [migration guide for v11.x](https://github.com/CircleCI-Public/orb-tools-orb/blob/v11.6.1/MIGRATION.md)._

### Notable Changes:

- **Removed the need for a dev publishing token**
  - Previously, after the orb was built, it would be published to a development tag and referenced in the test pipeline. This required a publishing token to be present in the dev pipeline.
  - The dynamic configuration system allows us to inject the orb directly into the pipeline as an "in-line" orb, allowing for orb testing without the need for access to a publishing token,
  thus allowing forked-PR builds to "build and test" securely.
- **Snake_Case Renamed Components**
  - To keep consistency with CircleCI's _native_ configuration schema, all components and parameters have been renamed to use snake_case.
  (Example: `parameter-name` -> `parameter_name`)
- **RC010 - Check for Snake_Case**
  - The `review` job will automatically check for snake_case naming conventions and provide an error if it detects a violation. This (like all RC checks) can be skipped.

### How to Migrate

1. Clone your orb project locally.
1. Create a new branch for upgrading your pipeline

   ```sh
   git checkout -b orb-tools-12-migration
   ````

1. Copy the `migrate.sh` script from this repository into your project's root directory.
1. Run the script

   ```sh
   chmod +x migrate.sh && ./migrate.sh
   ```

After executing the script, your orb's component names and parameters will be converted to snake_case, and references to them within your config files will be updated. The reference to your orb in the `test-deploy` config will be removed, as the orb will now be dynamically injected into the pipeline.

1. Edit your project's `.circleci/config.yml` file.

   Compare the current
[v12 "step1 " lint-pack example](https://circleci.com/developer/orbs/orb/circleci/orb-tools?version=12#usage-step1_lint-pack)
vs the
[v11 version](https://circleci.com/developer/orbs/orb/circleci/orb-tools?version=11#usage-step1_lint-pack)
to see the required changes.
   - Remove the old "dev publish" job (`orb-tools/publish`) from the workflow.
   - Fix the `requires:` specification so that the "continue" job requires everything else.

1. Edit your project's `.circleci/test-deploy.yml` file.

   Compare the current
[v12 "step2 " test-deploy example](https://circleci.com/developer/orbs/orb/circleci/orb-tools?version=12#usage-step2_test-deploy)
vs the
[v11 version](https://circleci.com/developer/orbs/orb/circleci/orb-tools?version=11#usage-step2_test-deploy)
to see the required changes.

   - Add an extra call to the "pack" job (`orb-tools/pack`) and ensure that the publish job(s) `require:` it.
   - Consider adding an extra call to the "publish" job to reinstate the "dev publish" removed from the `config.yml` build file.
     - Not all users will require this; this is only necessary if dev publishes of unreleased orbs are needed for use by other projects.
     - Consider setting a filter to ensure that the dev publish doesn't happen for release builds (i.e. no tags) or for external (forked) PR builds (i.e. no branches matching `/^pull/[0-9]+$/`).
   - Make the "pack" job `require:` all your test jobs and then have the publish job(s) `require:` the pack job.

---

## v11.0.0

Version 11.0.0 of orb-tools is composed of a major re-write that greatly changes and improves the way orbs are deployed, makes use of CircleCI's [dynamic configuration](https://circleci.com/docs/2.0/dynamic-config/), and can even automatically test for best practices.

### Notable changes:

- **Removed the 90 day limit**
  - Previously, the configuration relied on calling a `dev:alpha` tagged version of the orb for testing. Due to "dev" tags on CircleCI being ephemeral with a 90-day life span, if it had been over 90 days since the orb was last published this would result in an error in the CircleCI pipeline. Users would have to manually publish their orb locally to re-start the ci pipeline
  - The new dynamic configuration system allows us to publish the dev version of the orb _before_ calling it for testing. This means that the 90 day limit is no longer an issue.
- **Adopting Tag/Release based publishing**
  - Publishing previously required a special text flag to be added to the commit message and a new version was published on every merge to the main branch.
  - The new tag/release based publishing system will simply publish your orb when you opt to push a versioned tag or use GitHub's [releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) feature, which will create a tag and give you an opportunity to create a change log via [release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes).
- **Review system**
  - The new "review" job can automatically detect opportunities to improve best-practices and provide native JUNIT output which will be displayed in the CircleCI UI.
  - Modeled after _shellcheck_, it is easy to skip any "review check" by supplying its "RC" code in the "exclude" parameter of the job.
- **Simplified/Improved PR Commenting**
  - Automatically comment on the PR associated with a commit when each new orb version is published (dev or production.)
  - The comment will include a link to the Orb Registry to preview dev versions of the orb, and a live link to the production version of the orb.

### How to Migrate

1. Enable "[dynamic configuration](https://circleci.com/docs/2.0/dynamic-config/#getting-started-with-dynamic-config-in-circleci)" for your project on CircleCI.
   - Visit https://app.circleci.com/ and navigate to your project.
   - Click _Project Settings_ in the upper right corner.
   - Click _Advanced_
   - Toggle on _Enable Dynamic Configuration_
2. Clone your orb project locally.
3. Create a new branch for upgrading your pipeline
   - `git checkout -b orb-tools-11-migration`
4. Copy the `migrate.sh` script from this repository into your project's root directory.
5. Run the script
   - `chmod +x migrate.sh`
   - `bash migrate.sh`

6. After executing the script:

   - The script will ask you for some basic information about your orb, such as the namespace, name of the orb, and name of your publishing context. All of this information is present in your existing configuration.
   - Your existing configuration will be renamed to `config.yml.bak`
   - Two new configuration files will be downloaded from the template repository and modified with your inputs.
   - The migrate script will self-delete.
   - You will be asked to modify the generated `.circleci/test-deploy` to ensure any jobs you have defined and orb jobs are tested.

7. _(OPTIONAL)_ Enable PR comments.

   - When a new dev or production version of your orb is published, a comment will be added to the PR associated with the commit. NOTE: This will only be enabled if a GitHub token is provided
   - The comment will provide a live preview link of your orb on the Orb Registry.
   - Add `GITHUB_TOKEN` to your `<publishing-context>`.
     - If the repo is public, no scope is required.
     - You can find and edit your contexts in your CircleCI organization settings.
     - You can also [manage your contexts from the CLI](https://circleci.com/docs/2.0/local-cli/#context-management).

8. Add, commit and push your changes.

   1. `git add .circleci/config.yml .circleci/test-deploy.yml`
   1. `git commit -m "Add orb-tools config files"`
   1. `git push -u origin orb-tools-11-migration`

9. Publish the next version of your orb.

   _See Full Docs:_ [Publishing an Orb](https://circleci.com/docs/2.0/creating-orbs/)

- You can push a tag directly to the repository, or use the GitHub release feature (preferred).
- If you use the GitHub release feature, you will be able to create release notes.
- **NOTE:** In the previous versions of orb-tools, new versions of the orb were semi-automatically selected by using the commit message to detect the _type_ of change. This new system requires you to enter a full semantically versioned tag. It is important to double check the current live version of the orb and verify which version you intend to release next.
- **NOTE:** Remember, GitHub tags can be deleted or overwritten while orbs can not. Once an orb version has been published, the version itself must be incremented in order for any changes to be applied.
- **TIP:** Utilize [Conventional Commit Messages](https://conventionalcommits.org/) to help you decide what type of release to make based on the changes made in the previous commits.
