# AI Resume Recruiter

An AI-powered job search companion built on [Claude Code](https://claude.ai/code). Add your work experience and LinkedIn job URLs — Claude handles the rest: fetching job descriptions, discovering resume categories, generating tailored resumes, building PDFs, and tracking applications in Notion.

**Role-agnostic.** Works for engineers, product managers, designers, marketers, or any other role. Resume categories are discovered dynamically from your actual job listings, not hardcoded.

## Features

- **Automatic JD fetching** — paste LinkedIn URLs, Claude extracts the full job description
- **Dynamic categorization** — Claude analyzes your job batch and discovers natural groupings (e.g., "Frontend Engineering" vs "Full-Stack Product" vs "DevOps/Platform")
- **Tailored resumes** — one ATS-optimized resume per category, emphasizing the most relevant experience
- **PDF generation** — markdown to styled PDF via pandoc + weasyprint
- **Notion tracking** — optional sync to a Notion database for application status management
- **Incremental processing** — only new jobs are processed on each run; use `--force` to re-process all

## Prerequisites

- [Claude Code CLI](https://claude.ai/code) (or the desktop/web app)
- **For PDF generation:** [pandoc](https://pandoc.org/installing.html) and [weasyprint](https://doc.courtbouillon.org/weasyprint/stable/first_steps.html)
- **For Notion tracking (optional):** A Notion account with MCP integration configured

## Quick Start

### 1. Fork & Clone

```bash
git clone <your-fork-url>
cd Resumes
```

### 2. Configure

Edit `config.yaml` with your information:

```yaml
candidate:
  name: "Your Name"
  location: "City, State"
  email: "you@email.com"
  linkedin: "https://www.linkedin.com/in/yourprofile/"
```

### 3. Add Your Work Experience

Replace the example content in `work-experience.md` with your own career history. Follow the format:

```markdown
# Company Name
Brief company description

## Job Title
Role description
**Tags:** #relevant #tags

### Date
Start - End

### Projects

#### Project Name
- Bullet points with quantified results (numbers, %, $)
```

**Be verbose.** Include every project, metric, and achievement you can remember. The resume generation skills will distill this into polished bullet points. More detail = better resumes.

### 4. Add Job URLs

Paste LinkedIn job URLs into `LinkedIn Jobs.md`, one per line:

```markdown
## Jobs

https://www.linkedin.com/jobs/view/1234567890/
https://www.linkedin.com/jobs/view/9876543210/
```

### 5. Run the Pipeline

In Claude Code, run the full pipeline:

```
/recruiter
```

Or run individual steps:

```
/scan-jobs              # Fetch JDs and discover categories
/generate-resumes       # Create tailored resume MDs
/build-pdfs             # Convert to PDFs
/sync-notion            # Add to Notion database
```

## Skills Reference

### `/scan-jobs`

Fetches LinkedIn job descriptions, analyzes them, and assigns each to a resume category.

**Arguments:**
- `--force` — Re-process all URLs (including previously processed ones)

**What it does:**
1. Reads URLs from `LinkedIn Jobs.md`
2. Fetches each job description via WebFetch
3. If no categories exist: proposes 2-5 categories based on patterns in the JDs
4. If categories exist: assigns new jobs to the best match
5. Asks for user approval before creating/modifying categories
6. Saves results to `.processed-jobs.yaml` and `categories.yaml`

### `/generate-resumes`

Creates a tailored resume for each job category.

**Arguments:**
- `--force` — Regenerate all resumes
- `--category <name>` — Generate only for a specific category

**What it does:**
1. Reads your work experience and the category's JD signals
2. Selects the most relevant experience for each category
3. Generates ATS-friendly markdown with quantified bullet points
4. Saves to `Generated Resumes/`

### `/build-pdfs`

Converts resume markdown files to styled PDFs.

**Arguments:**
- `--category <name>` — Build only a specific category

**Requires:** `pandoc` and `weasyprint` installed locally.

### `/sync-notion`

Creates or updates entries in a Notion job applications database.

**Arguments:**
- `--force` — Re-sync all jobs (updates existing entries without overwriting Status)

**Requires:** Notion database configured in `config.yaml`.

### `/recruiter`

Runs the full pipeline: scan → generate → build → sync.

**Arguments:**
- `--force` — Re-process everything from scratch
- `--skip-pdf` — Skip PDF generation
- `--skip-notion` — Skip Notion sync

## Configuration Guide

### `config.yaml`

| Field | Description |
|-------|-------------|
| `candidate.name` | Your full name (used in resume headers and PDF filenames) |
| `candidate.location` | City, State (appears in resume header) |
| `candidate.email` | Contact email |
| `candidate.linkedin` | LinkedIn profile URL |
| `notion.database_id` | Notion database ID (leave blank to skip Notion) |
| `notion.data_source_id` | Notion MCP data source ID |
| `notion.year` | Current year for Notion entries |
| `paths.*` | File paths (defaults work for standard layout) |

### `categories.yaml`

Auto-generated by `/scan-jobs`. Each category has:

```yaml
- name: "Frontend Engineering"          # Display name
  description: "React/TypeScript roles" # Helps match future jobs
  signals:                              # JD keywords for this category
    - "React, TypeScript"
    - "Design systems"
  file_pattern: "Resume (Frontend Engineering)"  # Used in filename
```

You can edit this file manually to rename categories, adjust signals, or add new ones.

## Work Experience Format

The `work-experience.md` file uses a hierarchical structure:

```
Company → Job Title → Projects → Bullet Points
```

**Tips for writing good work experience:**

- **Be specific**: "Reduced API latency by 40%" > "Improved performance"
- **Include numbers**: Dollar amounts, percentages, user counts, team sizes, timelines
- **Use tags**: Add `#tags` to roles and projects so Claude can filter relevant experience
- **Don't self-edit**: Include everything — Claude picks what's relevant per category
- **Keep it messy**: This is a source document, not a polished resume

## How Categories Work

Categories are **discovered, not predefined**. Here's the flow:

1. **First run**: `/scan-jobs` analyzes all your JDs and proposes 2-5 categories based on patterns (shared tech stacks, domain keywords, role types)
2. **You approve**: Claude presents the proposed categories and waits for your OK
3. **Saved for reuse**: Categories are written to `categories.yaml`
4. **Future runs**: New jobs are matched to existing categories. If a job doesn't fit, Claude proposes a new category
5. **Manual editing**: You can always edit `categories.yaml` directly to rename, merge, or add categories

## Notion Setup

Notion integration is **optional**. To enable it:

1. **Create a Notion database** (full page, not inline) with these properties:

| Property | Type |
|----------|------|
| Job Title | title |
| Company | text |
| Job Link | url |
| Status | select (Not Applied, Applied, Interview, Offer, Rejected) |
| Resume Version | select |
| Category | select |
| Salary Min | number |
| Salary Max | number |
| Notes | rich text |
| Year | number |

2. **Get the database ID** from the URL: `https://notion.so/workspace/<database_id>?v=...`
3. **Add to config.yaml**:
   ```yaml
   notion:
     database_id: "your-database-id-here"
   ```
4. **Configure Notion MCP** in Claude Code so the Notion tools are available

## File Structure

```
Resumes/
├── config.yaml                    # Your settings (edit this first)
├── categories.yaml                # Auto-discovered resume categories
├── work-experience.md             # Your career history (source of truth)
├── LinkedIn Jobs.md               # Job URLs to process
├── .processed-jobs.yaml           # Pipeline tracking state (gitignored)
├── .gitignore
├── CLAUDE.md                      # Instructions for Claude Code
├── README.md                      # This file
├── Generated Resumes/
│   ├── build-resumes.sh           # MD → PDF converter
│   ├── resume-style.css           # PDF styling
│   ├── Name - Resume (Category).md    # Generated resume per category
│   └── Category/
│       └── Name Resume.pdf        # Built PDF
└── .claude/
    └── skills/
        ├── scan-jobs/SKILL.md
        ├── generate-resumes/SKILL.md
        ├── build-pdfs/SKILL.md
        ├── sync-notion/SKILL.md
        └── recruiter/SKILL.md
```

## Customization

### Changing PDF Styling

Edit `Generated Resumes/resume-style.css`. The default is a clean, professional layout optimized for ATS readability. Key settings:

- Page size: 8.5" x 11" (US Letter)
- Margins: 0.5"
- Font: System sans-serif stack
- Body text: 10pt

### Modifying Resume Rules

Resume generation logic lives in `.claude/skills/generate-resumes/SKILL.md`. You can adjust:

- Number of bullet points per role
- Summary length
- Formatting preferences
- Prioritization criteria

### Adding Non-LinkedIn Sources

Currently only LinkedIn URLs are supported via WebFetch. To add jobs from other sources, you can:

1. Manually paste JDs into individual files
2. Edit `.processed-jobs.yaml` to add entries with `jd_summary` filled in
3. Run `/generate-resumes` — it uses the summaries, not the original URLs

## Troubleshooting

**WebFetch fails for LinkedIn URLs**
- LinkedIn may block automated fetching. Try again after a few minutes.
- If persistent, manually copy the JD text and add it as a `jd_summary` in `.processed-jobs.yaml`.

**PDF build fails**
- Ensure `pandoc` and `weasyprint` are installed: `which pandoc && which weasyprint`
- On Linux, weasyprint may need: `apt install libpango-1.0-0 libcairo2`
- On macOS: `brew install pandoc && pip3 install weasyprint`

**Notion sync errors**
- Verify `notion.database_id` in `config.yaml` is correct
- Ensure the Notion MCP integration has access to the database
- Check that all required database properties exist (see Notion Setup)

**Categories seem wrong**
- Edit `categories.yaml` directly — rename, merge, or adjust signals
- Run `/scan-jobs --force` to re-categorize all jobs with updated categories
- Run `/generate-resumes --force` to regenerate resumes after category changes
