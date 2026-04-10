---
name: sync-notion
description: Create or update Notion database entries for processed jobs. Use --force to re-sync all jobs.
argument-hint: [--force]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - mcp__claude_ai_Notion__notion-create-pages
  - mcp__claude_ai_Notion__notion-search
  - mcp__claude_ai_Notion__notion-update-page
  - mcp__claude_ai_Notion__notion-fetch
---

# Sync Notion

Synchronize processed job entries to a Notion database for tracking applications.

## Workflow

### Step 1: Read Configuration

1. Read `config.yaml` for Notion settings (`database_id`, `data_source_id`, `year`).
2. If `notion.database_id` is empty or missing, stop with a message:
   > "Notion integration is not configured. Run `/setup-notion` to create a database automatically, or add your database ID to `config.yaml` manually. See README.md for details."
3. Read `.processed-jobs.yaml` for the list of processed jobs.

### Step 2: Determine Jobs to Sync

- If `$ARGUMENTS` contains `--force`: sync ALL jobs in the tracking file.
- Otherwise: only sync jobs where `notion_page_id` is empty or missing.
- If no jobs need syncing, report "All jobs are already synced to Notion" and stop.

### Step 3: Fetch Existing Notion Entries (Dedup Check)

1. Use `notion-search` or `notion-fetch` to check if entries already exist for these job URLs.
2. This prevents duplicates if a previous sync partially completed.
3. If a matching entry is found (by Job Link URL), record its page ID and skip creation.

### Step 4: Create New Entries

For each job needing creation, use `notion-create-pages` with the Notion database ID from config.

Map fields as follows:

| Tracking Field | Notion Property | Type | Value |
|---------------|-----------------|------|-------|
| `title` | Job Title | title | Job title from JD |
| `company` | Company | text | Company name |
| `url` | Job Link | url | LinkedIn URL |
| — | Status | select | "Not Applied" |
| `category` | Resume Version | select | Category name |
| `category` | Category | select | Category name |
| `salary_min` | Salary Min | number | Min salary (if available) |
| `salary_max` | Salary Max | number | Max salary (if available) |
| `jd_summary` | Notes | rich_text | JD summary from scan |
| config `year` | Year | number | From config.yaml |

### Step 5: Update Existing Entries (--force only)

When `--force` is used and a job already has a `notion_page_id`:

1. Use `notion-update-page` to refresh the fields above.
2. Do NOT overwrite the `Status` field — the user may have manually updated it (e.g., "Applied", "Interview").

### Step 6: Save Results

1. Update `.processed-jobs.yaml`: set `notion_page_id` for each synced job.
2. Output a summary table:

```
| Company | Title | Action | Notion Status |
|---------|-------|--------|---------------|
| Acme    | SWE   | Created | Not Applied  |
| BigCo   | TPM   | Skipped | Already exists|
```

## Error Handling

- If Notion MCP tools are not available (auth error, MCP not configured), provide clear instructions for setting up the Notion MCP integration.
- If a single page creation fails, log the error and continue with remaining jobs.
- If the database schema doesn't match (missing properties), warn the user about which properties need to be added.
- Never crash the entire sync for a single-job failure.

## Notion Database Setup

If the user hasn't set up their Notion database yet, provide these instructions:

1. Create a new Notion database (full page, not inline)
2. Add these properties:
   - **Job Title** (title) — this is the default title property
   - **Company** (text)
   - **Job Link** (url)
   - **Status** (select) — options: Not Applied, Applied, Interview, Offer, Rejected
   - **Resume Version** (select)
   - **Category** (select)
   - **Salary Min** (number)
   - **Salary Max** (number)
   - **Notes** (rich text)
   - **Year** (number)
3. Copy the database ID from the URL (the long hex string after the workspace name)
4. Paste it into `config.yaml` under `notion.database_id`
5. Ensure the Notion MCP integration has access to the database (share the database with the integration)
