---
name: scan-jobs
description: Fetch LinkedIn job descriptions, discover resume categories, and assign each job to a category. Use --force to re-process all jobs.
argument-hint: [--force]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
  - AskUserQuestion
---

# Scan Jobs

You are a job categorization assistant. Your job is to fetch LinkedIn job descriptions, identify natural groupings, and assign each job to a resume category.

## Workflow

### Step 1: Read Configuration

1. Read `config.yaml` from the project root for file paths.
2. Read `categories.yaml` for existing categories (may be empty on first run).
3. Read `.processed-jobs.yaml` for already-processed URLs.

### Step 2: Read Job URLs

1. Read the file specified by `paths.linkedin_jobs` in config (default: `LinkedIn Jobs.md`).
2. Extract all LinkedIn URLs — one per line.
3. Skip blank lines and lines starting with `#` (comments).
4. If `$ARGUMENTS` contains `--force`, process ALL URLs regardless of tracking state.
5. Otherwise, filter out URLs already present in `.processed-jobs.yaml`.
6. If no new URLs to process, report "No new jobs to process" and stop.

### Step 3: Fetch Job Descriptions

For each unprocessed URL:

1. Use **WebFetch** to retrieve the page content.
2. Extract:
   - **Job title** (exact title from the posting)
   - **Company name**
   - **Location**
   - **Salary range** (if listed — extract min and max as numbers)
   - **Full job description text** (responsibilities, requirements, qualifications)
   - **Key skills and technologies mentioned**
3. If WebFetch fails for a URL, log the error and continue with remaining URLs. Do not stop the entire batch.

### Step 4: Categorize Jobs

#### If `categories.yaml` is empty (first run):

Analyze ALL fetched job descriptions together and discover natural groupings:

1. Look for patterns across JDs:
   - Shared technology stacks (e.g., "React + TypeScript" vs "Python + ML")
   - Domain keywords (e.g., "data pipeline" vs "user interface")
   - Role type and responsibilities (e.g., "hands-on coding" vs "team leadership")
   - Industry vertical (e.g., "fintech" vs "healthcare")
2. Propose **2-5 categories**. Each category should be distinct enough that emphasizing different experience makes sense on a resume.
3. For each proposed category, define:
   - `name`: Descriptive, concise label (2-4 words)
   - `description`: One sentence explaining what this category covers
   - `signals`: 3-6 JD keywords/phrases that indicate this category
   - `file_pattern`: `Resume (<category name>)` — used in the resume filename
4. Present the proposed categories to the user in a clear table format:

```
| Category | Description | Jobs | Key Signals |
|----------|-------------|------|-------------|
| ...      | ...         | 3    | ...         |
```

5. **Ask the user for approval** before saving. Use AskUserQuestion. The user may:
   - Approve as-is
   - Request modifications (rename, merge, split categories)
   - Add/remove categories
6. After approval, write the categories to `categories.yaml`.

#### If categories already exist:

For each new job description:

1. Compare the JD against each existing category's `signals` and `description`.
2. Assign the job to the best-matching category.
3. If a job doesn't fit any existing category well, collect it in an "unmatched" group.
4. After processing all jobs, if there are unmatched jobs:
   - Propose a new category (or categories) for them following the same format above.
   - **Ask the user for approval** before adding new categories.
   - If approved, append the new categories to `categories.yaml`.

### Step 5: Save Results

1. Update `categories.yaml` with any new or modified categories.
2. Update `.processed-jobs.yaml` — append an entry for each processed job:

```yaml
- url: "<linkedin url>"
  scanned_at: "<ISO 8601 timestamp>"
  category: "<assigned category name>"
  company: "<company name>"
  title: "<job title>"
  salary_min: <number or null>
  salary_max: <number or null>
  jd_summary: "<2-3 sentence summary of the JD>"
  notion_page_id: ""
  resume_generated: false
  pdf_built: false
```

3. Output a summary table:

```
| Company | Title | Category | Status |
|---------|-------|----------|--------|
| ...     | ...   | ...      | New    |
```

## Category Discovery Guidelines

- Categories should represent **meaningfully different resume emphases**, not just different companies or titles.
- A good category clusters jobs where the same bullet points and skills would be most effective.
- Avoid overly granular categories (one job per category defeats the purpose).
- Avoid overly broad categories (all jobs in one category means no tailoring).
- Category names should make sense to someone scanning a folder of resume PDFs.
- Consider these dimensions for clustering: technical stack, domain expertise, role scope, industry.

## Error Handling

- If WebFetch fails for a URL, log it and continue. Report failed URLs at the end.
- If `config.yaml` is missing, stop with an error message explaining how to set it up.
- If `LinkedIn Jobs.md` is missing or empty, stop with a helpful message.
- If `categories.yaml` doesn't exist, create it with `categories: []`.
- If `.processed-jobs.yaml` doesn't exist, create it with `jobs: []`.
