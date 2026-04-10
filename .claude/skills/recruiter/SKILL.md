---
name: recruiter
description: Full recruiter pipeline — scan jobs, generate resumes, build PDFs, sync Notion. Use --force to re-process everything.
argument-hint: [--force] [--skip-pdf] [--skip-notion]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebFetch
  - AskUserQuestion
  - mcp__claude_ai_Notion__notion-create-pages
  - mcp__claude_ai_Notion__notion-search
  - mcp__claude_ai_Notion__notion-update-page
  - mcp__claude_ai_Notion__notion-fetch
---

# Recruiter Pipeline

You are a job search assistant running the full recruiter pipeline. This meta-skill chains four steps: scan jobs, generate resumes, build PDFs, and sync to Notion.

## Arguments

- `--force` — Re-process all jobs from scratch (passed through to each step)
- `--skip-pdf` — Skip the PDF build step (useful if pandoc/weasyprint aren't installed)
- `--skip-notion` — Skip Notion sync (useful if Notion isn't configured)

## Workflow

### Step 0: Validate Configuration

1. Read `config.yaml`.
2. Check that required fields are filled in:
   - `candidate.name` must not be "Jane Doe" or empty (placeholder check)
   - `candidate.email` must not be "jane.doe@email.com" or empty
3. If placeholders are detected, stop with:
   > "It looks like `config.yaml` still has placeholder values. Please fill in your actual information before running the pipeline. See README.md for details."
4. Read `LinkedIn Jobs.md` and verify it has at least one non-comment URL.
5. If no URLs found, stop with:
   > "No LinkedIn URLs found in `LinkedIn Jobs.md`. Add job URLs (one per line) and run again."

### Step 1: Scan Jobs

Follow the complete `/scan-jobs` workflow:

1. Read `categories.yaml` and `.processed-jobs.yaml`.
2. Extract new URLs from `LinkedIn Jobs.md` (or all if `--force`).
3. WebFetch each URL to get job descriptions.
4. Discover or assign categories.
5. **IMPORTANT**: If new categories are proposed, present them to the user and **wait for approval** before continuing. Do not proceed to resume generation until categories are confirmed.
6. Save results to `categories.yaml` and `.processed-jobs.yaml`.
7. Report scan results.

### Step 2: Generate Resumes

Follow the complete `/generate-resumes` workflow:

1. Read `work-experience.md` for source material.
2. For each category with jobs where `resume_generated: false` (or all if `--force`):
   - Generate a tailored resume following the formatting rules in the `/generate-resumes` skill.
   - Save to `Generated Resumes/{name} - {file_pattern}.md`.
3. Update `.processed-jobs.yaml` tracking.
4. Report which resumes were generated.

### Step 3: Build PDFs (unless --skip-pdf)

If `$ARGUMENTS` does NOT contain `--skip-pdf`:

1. Check that `pandoc` and `weasyprint` are available.
2. Run `cd "Generated Resumes" && ./build-resumes.sh`.
3. Verify PDFs were created.
4. Update tracking file.
5. Report results.

If tools aren't installed, warn the user but continue to Step 4 (don't fail the pipeline):
> "Skipping PDF build: pandoc/weasyprint not found. Run `cd 'Generated Resumes' && ./build-resumes.sh` from a terminal with these tools installed."

### Step 4: Sync to Notion (unless --skip-notion)

If `$ARGUMENTS` does NOT contain `--skip-notion`:

1. Check that `notion.database_id` is configured in `config.yaml`.
2. If not configured, skip with a message (don't fail):
   > "Skipping Notion sync: database_id not configured in config.yaml. See README.md for Notion setup."
3. If configured, follow the `/sync-notion` workflow to create/update entries.
4. Report sync results.

### Step 5: Final Summary

Output a combined summary:

```
## Pipeline Complete

### Jobs Scanned
- X new jobs processed, Y categories

### Resumes Generated
- Category A: Generated Resumes/...
- Category B: Generated Resumes/...

### PDFs Built
- Category A: Generated Resumes/Category A/Name Resume.pdf
- (or "Skipped — install pandoc + weasyprint to enable")

### Notion Sync
- X entries created
- (or "Skipped — configure notion.database_id to enable")
```

## Error Handling

- Each step should be as resilient as possible — a failure in one step should not prevent subsequent steps from running.
- If scan-jobs fails completely (no URLs, WebFetch errors for all), stop the pipeline since there's nothing to process.
- If generate-resumes fails for one category, continue with others.
- If build-pdfs fails, warn and continue to Notion sync.
- If sync-notion fails, warn and report in the final summary.
- Always output the final summary, even if some steps were skipped or had errors.
