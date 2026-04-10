---
name: setup-notion
description: One-time Notion database setup — creates the Job Applications database with correct schema, views, and saves IDs to config.yaml. Use when the user mentions setting up Notion, tracking applications, or when config.yaml has an empty notion.database_id.
allowed-tools:
  - Read
  - Edit
  - Glob
  - AskUserQuestion
  - mcp__claude_ai_Notion__notion-create-database
  - mcp__claude_ai_Notion__notion-create-view
  - mcp__claude_ai_Notion__notion-fetch
  - mcp__claude_ai_Notion__notion-search
---

# Setup Notion

One-time setup skill that creates a Notion job applications database and saves the IDs to `config.yaml`.

## Workflow

### Step 1: Check if Already Configured

1. Read `config.yaml`.
2. If `notion.database_id` is already filled in (non-empty), ask the user:
   > "A Notion database is already configured (ID: `...`). Do you want to create a new one, or keep the existing one?"
   - If they want to keep it, stop with: "Notion is already set up. Run `/sync-notion` to sync jobs."
   - If they want a new one, continue.

### Step 2: Ask Where to Create the Database

Use AskUserQuestion to ask the user:

> "Where should I create the Job Applications database?"

Options:
- **Workspace root** — creates as a top-level private page
- **Under an existing page** — user provides a Notion page URL or ID

If they choose an existing page, ask them to paste the page URL or ID.

### Step 3: Create the Database

Use `notion-create-database` with:

- **title**: "Job Applications"
- **description**: "Track job applications, resume versions, and application status. Managed by AI Resume Recruiter."
- **parent**: the page ID from Step 2 (if provided)
- **schema**:

```sql
CREATE TABLE (
  "Job Title" TITLE,
  "Company" RICH_TEXT,
  "Job Link" URL,
  "Status" SELECT(
    'Not Applied':default,
    'Applied':blue,
    'Interview':purple,
    'Offer':green,
    'Rejected':red
  ),
  "Resume Version" SELECT(),
  "Category" SELECT(),
  "Salary Min" NUMBER FORMAT 'dollar',
  "Salary Max" NUMBER FORMAT 'dollar',
  "Notes" RICH_TEXT,
  "Year" NUMBER
)
```

Record the returned **database_id** and **data_source_id** from the response.

### Step 4: Create Views

Create these views on the new database using `notion-create-view`:

1. **Board by Status** (board view):
   ```
   GROUP BY "Status"
   SHOW "Job Title", "Company", "Category", "Resume Version"
   ```

2. **By Category** (table view):
   ```
   GROUP BY "Category"
   SORT BY "Company" ASC
   SHOW "Job Title", "Company", "Status", "Resume Version", "Salary Min", "Salary Max"
   ```

### Step 5: Save to Config

1. Read `config.yaml`.
2. Update `notion.database_id` with the new database ID.
3. Update `notion.data_source_id` with the new data source ID.
4. Use the Edit tool to replace the empty values in `config.yaml`.

### Step 6: Report

Output a summary:

```
Notion database created successfully!

  Database: Job Applications
  ID: <database_id>
  Data Source: <data_source_id>

  Views created:
    - Board by Status (kanban)
    - By Category (table)

  Config updated: notion.database_id and notion.data_source_id saved to config.yaml

  Next steps:
    - Add LinkedIn URLs to LinkedIn Jobs.md
    - Run /scan-jobs to fetch and categorize jobs
    - Run /sync-notion to populate the database
    - Or run /recruiter to do everything at once
```

## Error Handling

- If Notion MCP is not authenticated, stop with: "Notion MCP is not connected. Please authenticate Notion in Claude Code first, then run /setup-notion again."
- If database creation fails, show the error and suggest checking Notion permissions.
- If view creation fails, warn but don't fail — the database is still usable without custom views.
- If config.yaml doesn't exist, stop with: "config.yaml not found. Please create it first (see README.md)."
