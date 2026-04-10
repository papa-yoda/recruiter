# Troubleshooting

## WebFetch fails for LinkedIn URLs

LinkedIn may block automated fetching. Try again after a few minutes.

If persistent, manually copy the JD text and add it as a `jd_summary` entry in `.processed-jobs.yaml`, then run `/generate-resumes`.

## PDF build fails

Verify tools are installed:

```bash
which pandoc && which weasyprint
```

Install if missing:
- **macOS:** `brew install pandoc && pip3 install weasyprint`
- **Linux:** `apt install pandoc && pip3 install weasyprint` (may also need `libpango-1.0-0` and `libcairo2`)

If running Claude Code in a devcontainer, run the build script from a host terminal instead:

```bash
cd "Generated Resumes" && ./build-resumes.sh
```

## Notion sync errors

- Verify `notion.database_id` in `config.yaml` matches the database URL
- Ensure the Notion MCP integration has been granted access to the database (share it with the integration)
- Check that all required properties exist in the database (see [Notion Setup](reference.md#notion-setup))

## Categories seem wrong

- Edit `categories.yaml` directly to rename, merge, or adjust signals
- Run `/scan-jobs --force` to re-categorize all jobs
- Run `/generate-resumes --force` to regenerate resumes after changes
