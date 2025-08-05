#!/bin/bash

# set -eux
set -o pipefail

# Check for required command dependencies
for cmd in llm glow; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: Required command '$cmd' not found" >&2
        exit 1
    fi
done

# Get filename argument with proper validation
fname="${1:-}"
if [ -z "$fname" ]; then 
    echo "Missing file name" >&2
    exit 1
fi
if [ ! -f "$fname" ]; then
    echo "Error: File '$fname' not found" >&2
    exit 1
fi

# Setup directories
base_crit_dir="$PWD/critiques"
bname=$(basename "$fname")
crit_dir="$base_crit_dir/$bname"
mkdir -p "$crit_dir"

# Get system prompt
if [ ! -f "$base_crit_dir/system-prompt.md" ]; then
    echo "Error: System prompt file not found" >&2
    exit 1
fi
sm=$(cat "$base_crit_dir/system-prompt.md")

# Count existing critiques and determine next index
amt=0
amt=$(find "$crit_dir" -mindepth 1 -name "*.md" | wc -l)
next_idx=$((amt+1))

# Prepare concatenated content from previous critiques
concatenated_content=""
if compgen -G "$crit_dir/*.md" > /dev/null; then
    while IFS= read -r file; do
        concatenated_content+="$file"$'\n'
        concatenated_content+="----------"$'\n'
        concatenated_content+="$(cat "$file")"$'\n\n'
    done < <(find "$crit_dir" -name "*.md" -type f | sort)
fi

# Prepare prompt
base_prompt="Provide a detailed analysis of the blog post that I just sent you. Be critical of issues related to flow and reader understanding, including syntax and spelling errors."
prompt="$base_prompt"

if [ -n "$concatenated_content" ]; then
    prompt="$prompt What follows are previous reports written by you, check if the file addressed the issues you proposed: $concatenated_content"
fi

# Generate and save critique
outfile="$crit_dir/${bname}_${next_idx}.md"
temp_outfile=$(mktemp)
cat "$fname" | llm prompt -u "$prompt" -s "$sm" -m claude-3.7-sonnet > "$temp_outfile"
llm_status=$?

# Check if the command succeeded
if [ $llm_status -eq 0 ]; then
    # Move the temporary file to the final location
    mv "$temp_outfile" "$outfile"
    # Display the result with glow
    glow -p "$outfile"
else
    echo "Error: LLM command failed" >&2
    rm -f "$temp_outfile"
    exit 1
fi
