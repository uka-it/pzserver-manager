#!/usr/bin/env bash
# Print the CHANGELOG.md section for a version (without its heading).
# Usage: changelog-notes.sh 2.0.0
version="$1"
changelog="$(dirname "$0")/../../CHANGELOG.md"

awk -v heading="## [$version]" '
    index($0, heading) == 1 { found = 1; next }
    found && /^## \[/       { exit }     # next version
    found && /^\[[0-9]/     { exit }     # link references at the end
    found                   { print }
' "$changelog" | sed -e '/./,$!d'        # drop leading blank lines
