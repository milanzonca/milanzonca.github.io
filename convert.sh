#!/bin/bash

# convert.sh
# Converts a Hugo markdown fulltext file to PDF via Pandoc
# Also generates a LaTeX-ready markdown file with margin note syntax
# Usage: ./convert.sh path/to/fulltext/index.md output.pdf

INPUT=$1
OUTPUT=${2:-output.pdf}
PREAMBLE="preamble.tex"
TEMP="temp_converted.md"

# Derive the latex-ready markdown filename from the output PDF name
LATEX_MD="${OUTPUT%.pdf}_latex.md"

# Check input file exists
if [ -z "$INPUT" ]; then
  echo "Usage: ./convert.sh path/to/fulltext/index.md [output.pdf]"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Error: File '$INPUT' not found."
  exit 1
fi

# Create LaTeX preamble if it does not exist
if [ ! -f "$PREAMBLE" ]; then
  echo "Creating preamble.tex..."
  cat > "$PREAMBLE" << 'PREAMBLE'
\usepackage{marginnote}
\usepackage{fontspec}
\usepackage{babel}
\babelprovide[main]{english}
\babelprovide{hebrew}
\babelfont[hebrew]{rm}{SBL Hebrew}
\setmainfont{Cardo}
PREAMBLE
fi

# Generate LaTeX-ready markdown file with Hugo shortcodes replaced
echo "Generating LaTeX-ready markdown: $LATEX_MD"
sed '/^bodyclass:/d' "$INPUT" \
  | sed 's/{{< pageref \([0-9]*\) *>}}/\\marginnote{p. \1}/g' \
  > "$LATEX_MD"

# Create temp file for Pandoc (same as latex-ready markdown)
cp "$LATEX_MD" "$TEMP"

# Convert to PDF using Pandoc with XeLaTeX
echo "Generating PDF: $OUTPUT"
pandoc "$TEMP" \
  -o "$OUTPUT" \
  --pdf-engine=xelatex \
  -H "$PREAMBLE"

# Clean up temp file
rm "$TEMP"

echo "Done."
echo "  PDF:              $OUTPUT"
echo "  LaTeX-ready .md:  $LATEX_MD"