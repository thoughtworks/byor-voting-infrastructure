# Contributing to byor-voting-server

First of all, thanks for taking the time to contribute to the project!

The following is a set of guidelines, not rules, for contributing. Feel free to propose changes to this document in a pull request.

#### Table Of Contents

[Code of Conduct](#code-of-conduct)

[Support from the community](#support-from-the-community)

[What should I know before I get started?](#what-should-i-know-before-i-get-started)

-   [BYOR](#byor)
-   [BYOR-VotingApp](#BYOR-VotingApp)
-   [Github repositories](#github-repositories)

[How Can I Contribute?](#how-can-i-contribute)

-   [Reporting Security Bugs](#reporting-security-bugs)
-   [Reporting Bugs](#reporting-bugs)
-   [Suggesting Enhancements](#suggesting-enhancements)
-   [Pull Requests](#pull-requests)

[Guidelines](#guidelines)

-   [Git Commit Checks](#git-commit-checks)
-   [Building for production](#build-for-production)

[Credits](#credits)

## Code of Conduct

This project and everyone participating in it is governed by the [Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Support from the community

You can find out more about how to get in touch with the community in [SUPPORT.md](SUPPORT.md)

## What should I know before I get started?

The BYOR-VotingApp is a companion app to [build-your-own-radar](https://github.com/thoughtworks/build-your-own-radar) project (aka BYOR).

### BYOR

Is a library that generates an interactive radar, inspired by [ThoughtWorks Technology Radar](http://thoughtworks.com/radar/).

The radar creation exercise invites you to have a conversation across all organizational levels and review your entire technology portfolio. This enables you to:

-   Objectively assess what's working, and what isn't
-   Pollinate innovation across teams and experiment accordingly
-   Balance the risk in your technology portfolio
-   Work out what kind of technology organization you want to be
-   Set a path for future success

You can generate the radar:

-   running locally the BYOR project
-   submitting your blips in Google Sheet or csv format to the [BUILD YOUR OWN RADAR](https://radar.thoughtworks.com) page
-   running the [BYOR-VotingApp](#BYOR-VotingApp), collecting blips and generating the radar on the fly

### BYOR-VotingApp

The BYOR-VotingApp helps you to collect blips and to enable conversations during the radar creation exercise.

The BYOR-VotingApp is a SPA (single page application) built with Angular 7 that interacts with a nodejs RESTful backend. Data is saved in a MongoDB database.

You can use your MongoDb of choice or provision it through the scripts provided in the infrastructure project.

### Github repositories

There is a github respository for the [front-end](https://github.com/thoughtworks/byor-voting-web-app), one for the [back-end](https://github.com/thoughtworks/byor-voting-server), plus one for setting up the necessary [infrastructure](https://github.com/thoughtworks/byor-voting-infrastructure) on Kubernetes or AWS lambda.

## How Can I Contribute?

### Reporting Security Bugs

Security bugs should not be reported as issues. You can find out more about how to report them correctly in [SECURITY.md](SECURITY.md)

### Reporting Bugs

When you are creating a bug report, please [include as many details as possible](#how-do-i-submit-a-good-bug-report). Fill out [the required template](.github/bug_report.md), the information it asks for helps us resolve issues faster.

> **Note:** If you find a **Closed** issue that seems like it is the same thing that you're experiencing, open a new issue and include a link to the original issue in the body of your new one.

#### Before Submitting A Bug Report

-   **Determine [which repository the problem should be reported in](#github-repositories)**.
-   **Perform a search in [issues](https://github.com/thoughtworks/byor-voting-web-app/issues)** to see if the problem has already been reported. If it has **and the issue is still open**, add a comment to the existing issue instead of opening a new one.

#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/). After you've determined [which repository](#github-repositories) your bug is related to, create an issue on that repository and provide the following information by filling in [the template](bug_report.md):

-   **Use a clear and descriptive title** for the issue to identify the problem.
-   **Describe the exact steps which reproduce the problem** in as many details as possible.
-   **Don't just say what you did, but explain how you did it**.
-   **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets, which you use in those examples. If you're providing snippets in the issue, use [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
-   **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
-   **Explain which behavior you expected to see instead and why.**
-   **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Provide more context by answering these questions:

-   **Did the problem start happening recently** (e.g. after updating to a new version) or was this always a problem?
-   If the problem started happening recently, **can you reproduce the problem in an older version?** What's the most recent version in which the problem doesn't happen?
-   **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.

### Suggesting Enhancements

When you are creating an enhancement suggestion, please [include as many details as possible](#how-do-i-submit-a-good-enhancement-suggestion). Fill in [the template](feature_request.md), including the steps that you imagine you would take if the feature you're requesting existed.

#### Before Submitting An Enhancement Suggestion

-   **Determine [which repository the enhancement should be suggested in](#github-repositories).**
-   **Perform a search in [issues](https://github.com/thoughtworks/byor-voting-web-app/issues)** to see if the enhancement has already been suggested. If it has, add a comment to the existing issue instead of opening a new one.

#### How Do I Submit A (Good) Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://guides.github.com/features/issues/). After you've determined [which repository](#github-repositories) your enhancement suggestion is related to, create an issue on that repository and provide the following information:

-   **Use a clear and descriptive title** for the issue to identify the suggestion.
-   **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
-   **Describe the current behavior** and **explain which behavior you expected to see instead** and why.


### Pull Requests

The process described here has several goals:

-   Maintain BYOR-VotingApp's quality
-   Fix problems that are important to users
-   Engage the community in working toward the best possible BYOR-VotingApp
-   Enable a sustainable system for BYOR-VotingApp's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in [the template](.github/pull_request_template.md)
2. Follow the [guidelines](#guidelines)
3. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing <details><summary>What if the status checks are failing?</summary>If a status check is failing, and you believe that the failure is unrelated to your change, please leave a comment on the pull request explaining why you believe the failure is unrelated. A maintainer will re-run the status check for you. If we conclude that the failure was a false positive, then we will open an issue to track that problem with our status check suite.</details>

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

## Guidelines

### Git Commit checks

#### Secrets disclosure prevention

Before committing any changes to the code base, a git pre-commit hook has to be installed in the local repository by executing the following command from the root directory of the project:

```shell
make enable_git_hooks
```

Having GNU Make, GNU Bash and Docker installed in the local machine is the prerequisite for running the pre-commit hook installed by the above command.

The pre-commit hook will run before any commit to scan the project files with [Talisman](https://github.com/thoughtworks/talisman), looking for things that seem suspicious, such as authorization tokens and private keys.

In case there is any suspect of being about to commit some secrets, the commit will be aborted and a detailed report of the suspicious contents will be printed out on the console. Please refer to [Talisman offical documentation](https://github.com/thoughtworks/talisman) for more details about secrets disclosure prevention.

### Build for Production

To build the app for production use:

```shell
helm dependency update src/byor-voting-chart
cd charts
helm package ../byor-voting-chart
cd ..
helm repo index charts/
```

:warning: **[*TODO*]** *review the rest of this paragraph*

If no environment variable named `BACKEND_SERVICE_URL` is existing in the current shell, the above command will interactively ask the user for the backend service URL he/she wants to target.

The build artifacts will be stored in the `dist/` directory.

## Credits

This guide has been built leveraging the examples found in [Gitub templates](https://help.github.com/en/articles/about-issue-and-pull-request-templates) and in [Atom repository](https://github.com/atom/atom).


## How to Helm

Updating Helm chart Version
-
* To update the chart version goto the relevant chart directory and update the version number in chart.yaml. run the below packaging command and build the index.

Packaging helm chart
-
* To package the helm chart goto the respective application folder were chart directory is present and run the folling command.
```shell
helm package src/byor-voting-web-app
helm repo index .
```
Packaing primary helm chart
-
* To package primary helm chart with all the dependecies, run the following command.

```shell
helm dep build src/byor-voting-chart
helm dependency update byor-voting-chart
cd charts
helm package ../byor-voting-chart
cd ..
helm repo index charts/

```

How to add byor repo to Helm repo
-
* To add byor repo to your helm repository, run the following command.

```shell

helm repo add byor-voting https://raw.githubusercontent.com/thoughtworks/byor-voting-infrastructure/master/charts

helm repo add byor-voting-app https://raw.githubusercontent.com/thoughtworks/byor-voting-web-app/master/charts

helm repo add byor-voting-server https://raw.githubusercontent.com/thoughtworks/byor-voting-server/master/charts

```













        	
   	
