# sample-robot-testing

Robot Framework tests for the deployed `handle_notes` cloud function.

## Required environment variable

Set the full function URL as `BASE_URL`.

Example:

```bash
export BASE_URL="https://your-region-your-project.cloudfunctions.net/handle_notes"
```

## Run locally

```bash
pip install -r requirements.txt
robot tests/notes_api.robot
```

## GitHub Actions

Provide `BASE_URL` as an environment variable or secret in your workflow.

## MongoDB schema (inferred)

Database: `notes_db`  
Collection: `notes_collection`

> Schema is inferred from a sample of documents and may not represent all fields.

| Field | BSON type(s) | Notes |
|---|---|---|
| `_id` | `ObjectId` | MongoDB document id |
| `name` | `String` | Note title/name |
| `content` | `String` | Note content |
