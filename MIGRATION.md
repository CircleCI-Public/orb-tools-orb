# Migration Guide

## v11.0.0

Version 11.0.0 of orb-tools is composed of a major re-write that greatly changes and improves the way orbs are deployed, makes use of CircleCI's [dynamic configuration](https://circleci.com/docs/2.0/dynamic-config/), and can even automatically test for best practices.

### Notable changes:

- **Removed the 90 day limit**
  - Previously, the configuration relied on calling a `dev:alpha` tag of the orb for testing. If it had been over 90 days since the orb was last published, this would result in an error in the CircleCI pipeline. Users would have to manually publish their orb locally to re-start the ci pipeline
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

## How to Migrate

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

7. _(OPTIONAL)_ Enable PR comments.

   - If a GitHub token is provided, when a new dev or production version of your orb is published, a comment will be added to the PR associated with the commit.
   - The comment will provide a live preview link of your orb on the Orb Registry.
   - Add `GITHUB_TOKEN` to your `<publishing-context>`.
     - UNKNOWN WHAT PERMISSIONS ARE NEEDED. tested with repo, possible no permissions needed.
   - You can find and edit your contexts in your CircleCI organization settings.

8. Add, commit and push your changes.

- `git add .circleci/config.yml .circleci/test-deploy.yml`
- `git commit -m "Add orb-tools config files"`
- `git push -u origin orb-tools-11-migration`

9. Publish the next version of your orb.

    _See Full Docs:_ [Publishing an Orb](https://circleci.com/docs/2.0/creating-orbs/)

- You can push a tag directly to the repository, or use the GitHub release feature (preferred).
- If you use the GitHub release feature, you will be able to create release notes.
- **NOTE:** In the previous versions of orb-tools, the next version of the orb was semi-automatically selected by being informed of the _type_ of change via the commit message. This new system requires you enter a full semantically versioned tag. So it is important to double check the currently live version of the orb and verify which version you intend to release next.
- **NOTE:** Remember, which GitHub tags can be deleted or overwritten, orbs can not. Once and orb version has been published, it must be incremented in version to apply any changes.
- **TIP:** Utilize [Conventional Commit Messages](https://conventionalcommits.org/) to help you decide what type of release to make based on the changes made in the previous commits.