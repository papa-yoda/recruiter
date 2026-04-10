#!/bin/bash
# Resume PDF Generator
# Converts markdown resumes to styled PDFs, organized by focus area

set -e

# Set library path for WeasyPrint dependencies (Homebrew on Apple Silicon)
if [[ "$(uname)" == "Darwin" ]]; then
    export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.yaml"
CSS_FILE="$SCRIPT_DIR/resume-style.css"

# Read candidate name from config.yaml
CANDIDATE_NAME=""
if [ -f "$CONFIG_FILE" ]; then
    CANDIDATE_NAME=$(grep '^\s*name:' "$CONFIG_FILE" | head -1 | sed 's/^[^"]*"\([^"]*\)".*/\1/')
fi
if [ -z "$CANDIDATE_NAME" ]; then
    echo "Warning: Could not read candidate name from config.yaml"
    echo "Falling back to extracting name from markdown filenames"
fi

# Find weasyprint: prefer PATH, fall back to known macOS location
if command -v weasyprint &> /dev/null; then
    WEASYPRINT="weasyprint"
else
    echo "Error: weasyprint not found on PATH"
    echo "Install with: pip3 install weasyprint"
    echo "  macOS: brew install weasyprint (or pip3 install weasyprint)"
    echo "  Linux: pip3 install weasyprint (may need libpango, libcairo)"
    exit 1
fi

# Check dependencies
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc not found. Install with: brew install pandoc (macOS) or apt install pandoc (Linux)"
    exit 1
fi

if [ ! -f "$CSS_FILE" ]; then
    echo "Error: CSS file not found at $CSS_FILE"
    exit 1
fi

echo "Building resumes..."
echo "==================="

# Process each markdown file with parentheses in the name (indicates focus area)
for md_file in "$SCRIPT_DIR"/*.md; do
    # Skip if no .md files exist
    [ -e "$md_file" ] || continue

    filename=$(basename "$md_file")

    # Extract focus area from parentheses: "Name - TPM Resume (Focus Area).md" -> "Focus Area"
    # Using sed to extract text between parentheses
    focus_area=$(echo "$filename" | sed -n 's/.*(\([^)]*\))\.md$/\1/p')

    if [ -n "$focus_area" ]; then

        echo ""
        echo "Processing: $filename"
        echo "  Focus area: $focus_area"

        # Create output directory
        output_dir="$SCRIPT_DIR/$focus_area"
        mkdir -p "$output_dir"

        # Determine output PDF name
        if [ -n "$CANDIDATE_NAME" ]; then
            output_pdf="$output_dir/$CANDIDATE_NAME Resume.pdf"
        else
            # Fall back: extract name from filename prefix (everything before " - ")
            fallback_name=$(echo "$filename" | sed 's/ - .*//')
            output_pdf="$output_dir/$fallback_name Resume.pdf"
        fi
        temp_html=$(mktemp).html

        # Convert markdown to HTML with embedded CSS
        # Enable autolink_bare_uris to convert plain URLs/emails to links
        pandoc "$md_file" \
            --standalone \
            --css="$CSS_FILE" \
            --metadata title="" \
            --from markdown+autolink_bare_uris \
            -o "$temp_html"

        # Convert HTML to PDF
        "$WEASYPRINT" "$temp_html" "$output_pdf"

        # Clean up temp file
        rm -f "$temp_html"

        echo "  Output: $output_pdf"
    fi
done

echo ""
echo "==================="
echo "Build complete!"
echo ""
echo "Generated PDFs:"
find "$SCRIPT_DIR" -name "*.pdf" -type f | while read pdf; do
    echo "  $pdf"
done
