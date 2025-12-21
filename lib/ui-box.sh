#!/usr/bin/env bash
###############################################################################
# Shared UI helpers for drawing boxes with consistent spacing
###############################################################################

if [ -n "${UI_BOX_HELPERS_LOADED:-}" ]; then
    return
fi
UI_BOX_HELPERS_LOADED=1

: "${BOX_INNER:=78}" # width inside the box (not counting left/right padding spaces)
: "${CYAN:=$'\033[0;36m'}"
: "${NC:=$'\033[0m'}"

if command -v python3 >/dev/null 2>&1; then
    UI_BOX_HAS_PYTHON3=1
else
    UI_BOX_HAS_PYTHON3=0
fi

_repeat_char() {
    local n="$1"
    local ch="$2"
    local out=""
    local i
    for ((i=0; i<n; i++)); do
        out+="$ch"
    done
    printf "%s" "$out"
}

_strip_ansi() {
    printf '%s' "$1" | sed -r $'s/\x1B\\[[0-9;]*[[:alpha:]]//g'
}

_display_width() {
    local plain="$(_strip_ansi "$1")"

    if ((UI_BOX_HAS_PYTHON3)); then
        python3 - "$plain" <<'PY'
import sys
import unicodedata

text = sys.argv[1]
width = 0
for ch in text:
    if unicodedata.combining(ch):
        continue
    if unicodedata.east_asian_width(ch) in ("F", "W"):
        width += 2
    else:
        width += 1
print(width, end="")
PY
    else
        local fallback_plain="$plain"
        fallback_plain="${fallback_plain//⚙/XX}"
        fallback_plain="${fallback_plain//🌐/XX}"
        fallback_plain="${fallback_plain//🔧/XX}"
        fallback_plain="${fallback_plain//🌍/XX}"
        fallback_plain="${fallback_plain//📋/XX}"
        fallback_plain="${fallback_plain//⚠/XX}"
        fallback_plain="${fallback_plain//✓/XX}"
        fallback_plain="${fallback_plain//✗/XX}"
        fallback_plain="${fallback_plain//●/XX}"
        fallback_plain="${fallback_plain//ℹ/XX}"
        printf '%s' "$fallback_plain" | wc -m | awk '{print $1}'
    fi
}

box_top() {
    printf "${CYAN}╔%s╗${NC}\n" "$(_repeat_char $((BOX_INNER + 2)) "═")"
}

box_mid() {
    printf "${CYAN}╠%s╣${NC}\n" "$(_repeat_char $((BOX_INNER + 2)) "═")"
}

box_bottom() {
    printf "${CYAN}╚%s╝${NC}\n" "$(_repeat_char $((BOX_INNER + 2)) "═")"
}

box_line() {
    local s="$1"
    local len pad
    len=$(_display_width "$s")
    pad=$((BOX_INNER - len))
    ((pad < 0)) && pad=0

    printf "${CYAN}║${NC} %s%*s ${CYAN}║${NC}\n" "$s" "$pad" ""
}

box_empty() {
    box_line ""
}

box_title_center() {
    local s="$1"
    local len left right
    len=$(_display_width "$s")

    if ((len >= BOX_INNER)); then
        box_line "$s"
        return
    fi

    left=$(( (BOX_INNER - len) / 2 ))
    right=$(( BOX_INNER - len - left ))

    printf "${CYAN}║${NC} %*s%s%*s ${CYAN}║${NC}\n" "$left" "" "$s" "$right" ""
}

box_header() {
    local title="$1"
    box_top
    box_title_center "$title"
    box_bottom
    echo ""
}
