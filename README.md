# sample-robot-testing

A small **Robot Framework** test suite for validating a deployed `handle_notes` HTTP cloud function (a simple Notes API).

This repository is intended to be used as a lightweight example of:
- running Robot Framework API tests locally, and
- running the same tests in CI (GitHub Actions) against an already-deployed endpoint.

## What’s in this repo

- `tests/notes_api.robot` — Robot Framework test cases that exercise the Notes API endpoints exposed by `handle_notes`.
- `requirements.txt` — Python dependencies required to run the tests.

## Prerequisites

- Python 3.x
- `pip`
- A deployed `handle_notes` function reachable over HTTPS

## Configuration

### Required environment variable

Set the full function URL as `BASE_URL`.

Example:

```bash
export BASE_URL="https://your-region-your-project.cloudfunctions.net/handle_notes"
```

Tip: `BASE_URL` should be the **root URL** for the function. The Robot tests will append any required paths/endpoints.

## Run locally

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the test suite:

```bash
robot tests/notes_api.robot
```

## CI / GitHub Actions

To run these tests in GitHub Actions, provide `BASE_URL` as an environment variable or (recommended) a repository secret, and map it into your workflow as an env var.

At minimum, your workflow should:
- check out the repo
- install dependencies from `requirements.txt`
- run `robot tests/notes_api.robot`

## Troubleshooting

- If tests fail with connection errors, verify `BASE_URL` is correct and publicly reachable from where you are running the tests (local machine or GitHub-hosted runner).
- If you see authentication/authorization errors, ensure your deployed function is configured to allow the type of access your tests expect.
