# Google Search Console OAuth Auth Notes

Use this when service account auth fails or when the user already owns the GSC property in their personal Google account.

## What worked

The `mcp-server-gsc` package requires `GOOGLE_APPLICATION_CREDENTIALS` and constructs Google auth with `GoogleAuth({ keyFile })`. Despite the package docs emphasizing service account JSON, `keyFile` also accepts an `authorized_user` OAuth JSON file.

This means `~/.config/gsc-credentials.json` can be either:
- service account JSON, or
- OAuth `authorized_user` JSON copied from gcloud ADC.

OAuth is better for properties the user already owns because GSC may reject service account emails in the UI with `Failed to add user: email not found`.

## gcloud flow

```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/webmasters.readonly

cp ~/.config/gcloud/application_default_credentials.json ~/.config/gsc-credentials.json
```

If gcloud is missing, install it or use a manual OAuth flow. Do not hardcode or print refresh tokens in chat.

## Required quota project

Search Console rejects local ADC user credentials without a quota project:

```text
MCP error 403: Your application is authenticating by using local Application Default Credentials. The searchconsole.googleapis.com API requires a quota project, which is not set by default.
```

Fix by adding this field to `~/.config/gsc-credentials.json`:

```json
"quota_project_id": "<google-cloud-project-id>"
```

The project must have Search Console API enabled.

## Verification

```bash
mcporter call gsc.list_sites --output json
```

Expected output includes GSC properties with `permissionLevel: siteOwner` or similar. If it returns `{}`, the authenticated identity has no visible properties.

Then test data:

```bash
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:example.com" \
  startDate="YYYY-MM-DD" \
  endDate="YYYY-MM-DD" \
  dimensions="query" \
  rowLimit:10 \
  --output json
```

Empty `rows` with only `responseAggregationType` means auth works but that property/date range has no matching search data.
