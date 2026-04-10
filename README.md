# AI Resume Recruiter

An AI-powered job search companion built on [Claude Code](https://claude.ai/code). Add your work experience and LinkedIn job URLs — Claude fetches job descriptions, discovers resume categories, generates tailored resumes, builds PDFs, and tracks applications in Notion.

Works for any role, industry, or career level. Categories are discovered from your actual job listings, not hardcoded.

## Prerequisites

**Required:**
- [Claude Code](https://claude.ai/code)

**Optional (for PDF generation):**
- [pandoc](https://pandoc.org/installing.html)
- [weasyprint](https://doc.courtbouillon.org/weasyprint/stable/first_steps.html)

**Optional (for application tracking):**
- [Notion MCP Server](https://developers.notion.com/guides/mcp/get-started-with-mcp)

## Setup

### Quick Setup (Recommended)

Fork & clone this repo, then run the interactive setup script:

```bash
./setup.sh
```

This will check dependencies, prompt for your info, and clear example content so you start fresh.

> **Windows users:** Use [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) (Windows Subsystem for Linux). Claude Code and this toolkit require a Unix shell.

### Manual Setup

1. **Edit `config.yaml`** — fill in your name, email, location, and LinkedIn URL
2. **Replace `work-experience.md`** with your own career history. Be verbose — include every project, metric, and achievement. Claude distills it into polished bullet points. The example file shows the expected format.
3. **Clear example content** — delete the example resumes in `Generated Resumes/` and reset `categories.yaml`
4. **Optionally set up Notion tracking** — run `/setup-notion` to create a job applications database automatically. Or set it up manually per [docs/reference.md](docs/reference.md#notion-setup).

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
