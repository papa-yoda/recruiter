#!/usr/bin/env bash
set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' YELLOW='' RED='' CYAN='' BOLD='' RESET=''
fi

info()    { printf "${CYAN}%s${RESET}\n" "$*"; }
success() { printf "${GREEN}✓ %s${RESET}\n" "$*"; }
warn()    { printf "${YELLOW}⚠ %s${RESET}\n" "$*"; }
error()   { printf "${RED}✗ %s${RESET}\n" "$*" >&2; exit 1; }

# ─── Script directory ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Idempotency check ───────────────────────────────────────────────────────

if [[ -f "$SCRIPT_DIR/config.yaml" ]]; then
    existing_name=$(grep -E '^\s+name:' "$SCRIPT_DIR/config.yaml" | head -1 | sed 's/.*"\(.*\)".*/\1/' || true)
    if [[ -n "$existing_name" && "$existing_name" != "Jane Doe" ]]; then
        warn "config.yaml is already configured for \"$existing_name\"."
        printf "Running setup again will overwrite your configuration. Continue? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            info "Setup cancelled."
            exit 0
        fi
    fi
fi

# ─── Dependency checks ───────────────────────────────────────────────────────

info "Checking dependencies..."
echo

missing_optional=()

if command -v claude &>/dev/null; then
    success "claude CLI found"
else
    error "Claude Code CLI is required. Install it from https://claude.ai/code"
fi

if command -v pandoc &>/dev/null; then
    success "pandoc found"
else
    missing_optional+=("pandoc")
    warn "pandoc not found — PDF generation will not work"
    echo "  Install: brew install pandoc (macOS) / apt install pandoc (Linux)"
fi

if command -v weasyprint &>/dev/null; then
    success "weasyprint found"
else
    missing_optional+=("weasyprint")
    warn "weasyprint not found — PDF generation will not work"
    echo "  Install: pip install weasyprint"
fi

echo
if [[ ${#missing_optional[@]} -gt 0 ]]; then
    info "Optional dependencies missing: ${missing_optional[*]}"
    info "You can install them later if you want PDF generation."
else
    success "All dependencies found"
fi
echo

# ─── Collect candidate info ──────────────────────────────────────────────────

printf "${BOLD}Let's set up your profile.${RESET}\n\n"

# Name (required)
while true; do
    printf "Full name: "
    read -r NAME
    [[ -n "$NAME" ]] && break
    warn "Name is required."
done

# Email (required, basic validation)
while true; do
    printf "Email address: "
    read -r EMAIL
    if [[ "$EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
        break
    fi
    warn "Please enter a valid email address."
done

# Location (required)
while true; do
    printf "Location (e.g. City, State): "
    read -r LOCATION
    [[ -n "$LOCATION" ]] && break
    warn "Location is required."
done

# LinkedIn (optional)
printf "LinkedIn profile URL (optional, press Enter to skip): "
read -r LINKEDIN
if [[ -n "$LINKEDIN" && ! "$LINKEDIN" =~ ^https?://(www\.)?linkedin\.com/in/ ]]; then
    warn "URL doesn't look like a LinkedIn profile, but saving it anyway."
fi

echo

# ─── Notion integration ──────────────────────────────────────────────────────

NOTION_DB_ID=""
NOTION_DS_ID=""

printf "Set up Notion integration for application tracking? (y/N): "
read -r setup_notion
if [[ "$setup_notion" =~ ^[Yy]$ ]]; then
    echo
    info "You can find your database ID in the Notion URL:"
    echo "  https://www.notion.so/<workspace>/<database_id>?v=..."
    echo

    while true; do
        printf "Notion database ID: "
        read -r NOTION_DB_ID
        [[ -n "$NOTION_DB_ID" ]] && break
        warn "Database ID is required for Notion integration."
    done

    while true; do
        printf "Notion data source ID (for MCP): "
        read -r NOTION_DS_ID
        [[ -n "$NOTION_DS_ID" ]] && break
        warn "Data source ID is required for Notion integration."
    done
fi

echo

# ─── Sanitize inputs for YAML ────────────────────────────────────────────────

yaml_escape() { printf '%s' "${1//\"/\\\"}"; }

NAME_SAFE=$(yaml_escape "$NAME")
EMAIL_SAFE=$(yaml_escape "$EMAIL")
LOCATION_SAFE=$(yaml_escape "$LOCATION")
LINKEDIN_SAFE=$(yaml_escape "$LINKEDIN")
NOTION_DB_SAFE=$(yaml_escape "$NOTION_DB_ID")
NOTION_DS_SAFE=$(yaml_escape "$NOTION_DS_ID")
CURRENT_YEAR=$(date +%Y)

# ─── Write config.yaml ───────────────────────────────────────────────────────

info "Writing config.yaml..."

cat > "$SCRIPT_DIR/config.yaml" << ENDCONFIG
# =============================================================
# Resume Recruiter Configuration
# Fill in your details below, then run /recruiter to get started
# =============================================================

candidate:
  name: "${NAME_SAFE}"
  location: "${LOCATION_SAFE}"
  email: "${EMAIL_SAFE}"
  linkedin: "${LINKEDIN_SAFE}"

# Notion Job Applications Database (optional)
#
# To use Notion tracking, create a database with these properties:
#   - Job Title    (title)
#   - Company      (text)
#   - Job Link     (url)
#   - Status       (select: Not Applied, Applied, Interview, Offer, Rejected)
#   - Resume Version (select)
#   - Category     (select)
#   - Salary Min   (number)
#   - Salary Max   (number)
#   - Notes        (rich_text)
#   - Year         (number)
#
# Then paste the database ID below. Find it in the Notion URL:
#   https://www.notion.so/<workspace>/<database_id>?v=...
#
# Leave blank to skip Notion integration entirely.
notion:
  database_id: "${NOTION_DB_SAFE}"
  data_source_id: "${NOTION_DS_SAFE}"
  year: ${CURRENT_YEAR}

# File paths (relative to this directory)
# Adjust if you rename or move files
paths:
  work_experience: "work-experience.md"
  linkedin_jobs: "LinkedIn Jobs.md"
  generated_resumes: "Generated Resumes/"
  categories: "categories.yaml"
  tracking: ".processed-jobs.yaml"
ENDCONFIG

success "config.yaml written"

# ─── Reset work-experience.md ────────────────────────────────────────────────

info "Resetting work-experience.md..."

cat > "$SCRIPT_DIR/work-experience.md" << 'ENDWORK'
# Work Experience

## About This Document

This is a stream-of-consciousness career history. It's intentionally verbose and unpolished — the goal is to capture everything you've done so that Claude can cherry-pick the most relevant achievements for each resume variant.

**Do not clean this up.** More detail is always better. Include numbers, dollar amounts, percentages, team sizes, timelines, and tools used. The resume generation skills will distill this into polished bullet points.

## Work Experience Structure

```
# Company Name
Brief description of the company

## Job Title
Blurb about the role
**Tags:** #relevant-tags

### Date
Start - End

### Projects

#### Project Name
**Tags:** #project-specific-tags
- Bullet points about what you did
- Include quantified results wherever possible
```

## Tagging System

Tags help Claude filter relevant experience for specific job categories. Use any tags that make sense for your field. Examples:

- **Role types:** #frontend, #backend, #fullstack, #management, #design
- **Technical domains:** #react, #python, #aws, #databases, #devops
- **Industries:** #fintech, #healthcare, #ecommerce, #saas
- **Impact types:** #cost-reduction, #performance, #revenue, #user-growth

---

<!-- Add your work experience below -->
ENDWORK

success "work-experience.md reset"

# ─── Reset LinkedIn Jobs.md ──────────────────────────────────────────────────

info "Resetting LinkedIn Jobs.md..."

cat > "$SCRIPT_DIR/LinkedIn Jobs.md" << 'ENDJOBS'
# LinkedIn Jobs

Add LinkedIn job URLs below, one per line. Lines starting with `#` are comments and will be ignored. Blank lines are also ignored.

When you're ready, run `/scan-jobs` to fetch job descriptions and categorize them, or `/recruiter` to run the full pipeline.

## Jobs

# Paste LinkedIn URLs here, for example:
# https://www.linkedin.com/jobs/view/1234567890/
# https://www.linkedin.com/jobs/view/9876543210/
ENDJOBS

success "LinkedIn Jobs.md reset"

# ─── Delete example resumes ──────────────────────────────────────────────────

info "Clearing example resumes..."

find "$SCRIPT_DIR/Generated Resumes" -maxdepth 1 -name "*.md" -type f -delete 2>/dev/null || true
find "$SCRIPT_DIR/Generated Resumes" -mindepth 1 -type d -exec rm -rf {} + 2>/dev/null || true

success "Example resumes cleared"

# ─── Reset categories.yaml ───────────────────────────────────────────────────

info "Resetting categories.yaml..."

cat > "$SCRIPT_DIR/categories.yaml" << 'ENDCATS'
# Auto-generated by /scan-jobs — you can also edit manually
#
# Each category represents a distinct resume variant. When /scan-jobs
# discovers natural groupings in your job listings, it saves them here.
# Future runs reuse these categories for new jobs.
#
# Format:
#   - name: "Category Name"
#     description: "Brief description of what this category covers"
#     signals:
#       - "JD keyword or phrase that indicates this category"
#     file_pattern: "Resume (Category Name)"
#
categories: []
ENDCATS

success "categories.yaml reset"

# ─── Reset .processed-jobs.yaml ──────────────────────────────────────────────

info "Resetting .processed-jobs.yaml..."

cat > "$SCRIPT_DIR/.processed-jobs.yaml" << 'ENDTRACKING'
# Auto-managed by /scan-jobs — do not edit manually
#
# Tracks which LinkedIn URLs have been processed through the pipeline.
# Each entry records: URL, company, title, assigned category, and
# whether resume generation and PDF build have been completed.
#
jobs: []
ENDTRACKING

success ".processed-jobs.yaml reset"

# ─── Summary ─────────────────────────────────────────────────────────────────

NOTION_STATUS="Not configured"
if [[ -n "$NOTION_DB_ID" ]]; then
    NOTION_STATUS="Configured"
fi

echo
printf "${BOLD}=====================================${RESET}\n"
printf "${BOLD}  Setup complete!${RESET}\n"
printf "${BOLD}=====================================${RESET}\n"
echo
printf "  ${BOLD}Name:${RESET}     %s\n" "$NAME"
printf "  ${BOLD}Email:${RESET}    %s\n" "$EMAIL"
printf "  ${BOLD}Location:${RESET} %s\n" "$LOCATION"
if [[ -n "$LINKEDIN" ]]; then
    printf "  ${BOLD}LinkedIn:${RESET} %s\n" "$LINKEDIN"
fi
printf "  ${BOLD}Notion:${RESET}   %s\n" "$NOTION_STATUS"
echo
printf "  ${BOLD}Next steps:${RESET}\n"
echo "  1. Add your work experience to work-experience.md"
echo "  2. Paste LinkedIn job URLs into LinkedIn Jobs.md"
echo "  3. Run /recruiter to generate tailored resumes"
echo
