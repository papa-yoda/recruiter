---
name: build-pdfs
description: Convert resume markdown files to PDFs using build-resumes.sh. Requires pandoc and weasyprint.
argument-hint: [--category <name>]
allowed-tools:
  - Read
  - Bash
  - Glob
  - Edit
---

# Build PDFs

Convert generated resume markdown files into styled PDFs.

## Workflow

### Step 1: Check Prerequisites

1. Read `config.yaml` for candidate name and paths.
2. Run `which pandoc` and `which weasyprint` to verify both are installed.
3. If either is missing:
   - If running in a devcontainer, these tools likely aren't available here. Tell the user to run the build from their host terminal instead: `cd "Generated Resumes" && ./build-resumes.sh`
   - Otherwise, provide install instructions:
     - **pandoc**: `brew install pandoc` (macOS) or `apt install pandoc` (Linux)
     - **weasyprint**: `pip3 install weasyprint` (may need `libpango` and `libcairo` on Linux)
   - Stop after providing the appropriate guidance.
4. Verify `Generated Resumes/build-resumes.sh` exists and is executable.
5. Verify `Generated Resumes/resume-style.css` exists.

### Step 2: Verify Resume Files Exist

1. Check that there are `.md` resume files in `Generated Resumes/` with parentheses in the filename (the build script uses this to determine the output subdirectory).
2. If `$ARGUMENTS` contains `--category <name>`, verify the specific resume file for that category exists.
3. If no resume markdown files are found, advise running `/generate-resumes` first.

### Step 3: Run Build Script

1. Execute: `cd "Generated Resumes" && ./build-resumes.sh`
2. The script will:
   - Read the candidate name from `config.yaml`
   - Convert each `.md` file to HTML via pandoc
   - Convert HTML to PDF via weasyprint
   - Place PDFs in subdirectories named after the focus area in parentheses
3. Monitor the output for errors.

### Step 4: Verify and Report

1. Check that PDFs were created in the expected subdirectories.
2. List the generated files with sizes.
3. Update `.processed-jobs.yaml`: set `pdf_built: true` for jobs in categories whose PDFs were successfully built.
4. Report results:

```
Generated PDFs:
  Generated Resumes/Frontend Engineering/Jane Doe Resume.pdf (142 KB)
  Generated Resumes/Full-Stack Product/Jane Doe Resume.pdf (138 KB)
```

## Error Handling

- If the build script fails, show the error output and suggest common fixes.
- If `config.yaml` is missing, the script falls back to extracting the name from the markdown filename.
- If weasyprint has font/rendering issues, suggest installing system fonts or checking CSS paths.

