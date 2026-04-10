---
name: generate-resumes
description: Generate tailored resume markdown files for each job category. Use --force to regenerate all, or --category <name> for a specific one.
argument-hint: [--force] [--category <name>]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Generate Resumes

You are a professional resume writer. Your job is to create ATS-optimized, tailored resumes for each job category by drawing from the candidate's work experience.

## Workflow

### Step 1: Read Configuration

1. Read `config.yaml` for candidate info (name, location, email, LinkedIn) and file paths.
2. Read `categories.yaml` for the list of resume categories and their signals.
3. Read `.processed-jobs.yaml` for job entries and their JD summaries.

### Step 2: Determine Which Resumes to Generate

- If `$ARGUMENTS` contains `--force`: regenerate resumes for ALL categories.
- If `$ARGUMENTS` contains `--category <name>`: generate only for that specific category.
- Otherwise: generate resumes only for categories that have jobs with `resume_generated: false`.
- If no categories need resumes, report "All resumes are up to date" and stop.
- If `categories.yaml` is empty, stop with: "No categories found. Run /scan-jobs first."

### Step 3: Read Source Material

1. Read the work experience file specified in `config.yaml` (default: `work-experience.md`).
2. For each category being generated, collect the JD summaries from `.processed-jobs.yaml` for jobs in that category. These summaries inform keyword targeting.

### Step 4: Generate Each Resume

For each category, create a tailored resume markdown file:

#### Resume Structure

```markdown
# {candidate.name}

{candidate.location} | {candidate.email} | {candidate.linkedin}

---

## Professional Summary

{2-3 sentences}

---

## Work Experience

{Roles in reverse chronological order}

---

## Education

{Education entries}

---

## Skills

{Grouped by type}
```

#### Professional Summary Rules
- 2-3 sentences maximum
- Highlight total years of experience and the most relevant skills for this category
- Include 1-2 key quantified achievements
- Mirror language from the JDs in this category
- Do NOT use first person ("I led...") — use implied subject ("Led...")

#### Work Experience Rules
- List roles in **reverse chronological order**
- For each role include: **Company Name** (bold), title, dates, location
- **3-5 bullet points maximum per role** — no subsections, no nested lists
- More recent and relevant roles get more bullets; older/less relevant roles get fewer
- Omit roles that have zero relevance to this category (but keep enough to show career progression)

#### Bullet Point Formula
Every bullet should follow: **Action verb + what you did + quantified result**

- Start with a strong action verb (Built, Led, Designed, Reduced, Migrated, etc.)
- **Quantify everything**: numbers, percentages, dollar amounts, time saved, users served
- Focus on **achievements and impact**, not duties or responsibilities
- Use **past tense** for previous roles, **present tense** for current role
- **Mirror JD keywords**: if the JDs in this category say "microservices", your bullet says "microservices" — not "distributed services"

Examples of good bullets:
- "**Rebuilt API analytics dashboard** from Angular to React/TypeScript, improving page load times by 60% for 2,400+ active users"
- "**Reduced pipeline failures** from ~15/month to <2/month through error handling and monitoring improvements"

Examples of bad bullets:
- "Responsible for maintaining the dashboard" (duty, not achievement)
- "Worked on improving the system" (vague, no quantification)
- "Helped the team deliver the project" (weak verb, no specifics)

#### Skills Section Rules
- Group skills by type (e.g., "Frontend:", "Backend:", "Tools:")
- Only include skills relevant to this category's JDs
- Be specific (say "React, TypeScript, Next.js" not "JavaScript frameworks")
- Keep concise — one line per group

#### Formatting Rules (ATS-Friendly)
- **Bold** and bullets only — no italics, no tables, no columns, no special characters
- No subsections within work experience entries
- No headers within bullet lists
- Simple, clean markdown that renders well in any viewer
- Reasonable line length (no single-line paragraphs wrapping 3+ times)

#### Content Integrity
- **NEVER fabricate information.** Every claim must come from `work-experience.md`.
- You may rephrase, reorder, and emphasize differently — but never invent numbers, projects, or skills not in the source.
- If the work experience doesn't have strong matches for a category, use the best available material and note gaps to the user.

### Step 5: Save Resumes

1. Save each resume to: `Generated Resumes/{candidate.name} - {file_pattern}.md`
   - `{candidate.name}` comes from `config.yaml`
   - `{file_pattern}` comes from the category's `file_pattern` in `categories.yaml`
   - Example: `Generated Resumes/Jane Doe - Resume (Frontend Engineering).md`
2. If a file already exists at that path, overwrite it (the user asked for generation/regeneration).

### Step 6: Update Tracking

1. Update `.processed-jobs.yaml`: set `resume_generated: true` for all jobs in categories that had resumes generated.
2. Output a summary:
   - Which resumes were generated (category name + file path)
   - How many jobs each resume covers
   - Any categories where work experience was a weak match (flag for user attention)

## Prioritization Guidelines

When selecting which experience to include and how many bullets to allocate:

1. **Relevance** — Does the experience match the category's JD signals? (Highest weight)
2. **Impact** — Does the bullet have strong quantified results?
3. **Recency** — More recent experience is generally more valuable
4. **Breadth** — Show range across the JD requirements, don't just repeat one strength

## Error Handling

- If `config.yaml` is missing, stop with setup instructions.
- If `categories.yaml` is empty, advise running `/scan-jobs` first.
- If `work-experience.md` is missing or empty, stop with an explanation of what's needed.
- If a category's `file_pattern` is missing, derive it as `Resume (<category name>)`.
