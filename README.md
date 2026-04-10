# AI Resume Recruiter

An AI-powered job search companion built on [Claude Code](https://claude.ai/code). Add your work experience and LinkedIn job URLs — Claude fetches job descriptions, discovers resume categories, generates tailored resumes, builds PDFs, and tracks applications in Notion.

Works for any role, industry, or career level. Categories are discovered from your actual job listings, not hardcoded.

## Prerequisites

- [Claude Code](https://claude.ai/code)
- [pandoc](https://pandoc.org/installing.html) + [weasyprint](https://doc.courtbouillon.org/weasyprint/stable/first_steps.html) (for PDF generation)

## Setup

1. **Fork & clone** this repo
2. **Edit `config.yaml`** — fill in your name, email, location, and LinkedIn URL
3. **Replace `work-experience.md`** with your own career history. Be verbose — include every project, metric, and achievement. Claude distills it into polished bullet points. The example file shows the expected format.
4. **Optionally configure Notion** — add your database ID to `config.yaml` for application tracking. See [Notion setup](docs/reference.md#notion-setup).

## Usage

Add LinkedIn job URLs to `LinkedIn Jobs.md` (one per line), then run:

```
/recruiter
```

This runs the full pipeline: fetches JDs, proposes resume categories for your approval, generates tailored resumes, builds PDFs, and syncs to Notion.

You can also run steps individually:

```
/scan-jobs           # Fetch JDs and discover categories
/generate-resumes    # Create resume markdown files
/build-pdfs          # Convert to PDFs
/sync-notion         # Sync to Notion
```

All skills support `--force` to re-process from scratch. See [docs/reference.md](docs/reference.md) for full argument details.

## How It Works

1. `/scan-jobs` fetches your LinkedIn job descriptions and clusters them into 2-5 categories based on shared signals (tech stack, domain, role type). You approve the categories before anything is saved.
2. `/generate-resumes` creates one ATS-optimized resume per category, drawing from your work experience and matching JD keywords.
3. Future runs are incremental — only new URLs are processed. Categories persist in `categories.yaml` and can be edited manually.

## Further Reading

- [Reference](docs/reference.md) — skill arguments, configuration fields, categories, customization
- [Troubleshooting](docs/troubleshooting.md) — common issues with WebFetch, PDF builds, and Notion
