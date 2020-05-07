# Contributing to fiskaly-sdk-swift

## Bugs

We use [GitHub Issues](https://github.com/fiskaly/fiskaly-sdk-swift/issues) for our bugs. If you would like to report a problem, take a look around and see if someone already opened an issue about it. If you are certain this is a new, unreported bug, you can submit a [bug report](#reporting-new-issues).

## Reporting New Issues

When [opening a new issue](https://github.com/fiskaly/fiskaly-sdk-swift/issues/new/choose), always make sure to fill out the issue template. **This step is very important!** Not doing so may result in your issue not being managed in a timely fashion. Don't take this personally if this happens, and feel free to open a new issue once you've gathered all the information required by the template.

- **One issue, one bug:** Please report a single bug per issue.
- **Provide reproduction steps:** List all the steps necessary to reproduce the issue. The person reading your bug report should be able to follow these steps to reproduce your issue with minimal effort.
- **Optional: Add a log-file:** If your problem has to do with the client, make sure to enable the Debug-Mode and attach the generated log-file to your issue.
- **Optional: Add a request-id:** If you are having a problem with one of our APIs and you are receiving a response from said API, make sure to add the Request-ID from the headers so we can check out the request easily without the need to search for it.

## Pull Requests

### Proposing a Change

If you would like to request a new feature or enhancement but are not yet thinking about opening a pull request, you can also file an issue with [feature template](https://github.com/fiskaly/fiskaly-sdk-swift/issues/new?template=feature.md).

If you're only fixing a bug, it's fine to submit a pull request right away but we still recommend to file an issue detailing what you're fixing. This is helpful in case we don't accept that specific fix but want to keep track of the issue.

### Sending a Pull Request

Small pull requests are much easier to review and more likely to get merged. Make sure the PR does only one thing, otherwise please split it.

Please make sure the following is done when submitting a pull request:

1. Fork [the repository](https://github.com/fiskaly/fiskaly-sdk-swift) and create your branch from `master`.
2. Mention that you are working on something directly in the issue. This way we can ensure that no more than one person is working on an issue.
3. Describe your [**test plan**](#test-plan) in your pull request description. 
4. Make sure to test your changes locally as not all tests are run in the github-workflow.
5. [**Lint**](#linter) your changes and make sure to address warnings and errors.

All pull requests should be opened against the `master` branch.

#### Test Plan

A good test plan adds various tests to the repository to ensure that the newly added functionality is working as intended or the bug is fixed. You can: 
- Add more test cases to alreay existing test-files
- Create a new test-file with your test-cases

Currently tests that involve authentication with our APIs will not be tested automatically with Github-Actions, because of the way Github handles secrets. If your test-plan include such tests, make sure to mention them in the pull request and test them locally. 
Add these tests to the `skip-testing`-flag in the github-workflow, so the workflow does not fail because of that.

We may close pull request with failing tests immediately, with or without comment, so make sure that the tests are running successfully.

#### Breaking Changes

When adding a new breaking change, follow this template in your pull request:

```md
### New breaking change here
- **How to migrate**:
- **Why make this breaking change**:
```

### Code Conventions

#### General

- **Most important: Look around.** Match the style you see used in the rest of the project. This includes formatting, naming files, naming things in code, naming things in documentation.
- "Attractive"

## Linter

`fiskaly-sdk-swift` uses [SwiftLint](https://github.com/realm/SwiftLint) to check for Swift coding conventions. The linter runs in every pull request as well as every commit pushed to master. Before submitting a new pull request make sure you let the linter run locally on the files you have changed.

## License

By contributing to `fiskaly-sdk-swift`, you agree that your contributions will be licensed under its MIT license.