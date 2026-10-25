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

# Number of terminal columns a string takes. Wide characters (emoji like 🌐,
# CJK) count 2, combining marks and variation selectors 0, everything else 1
# (including symbols like ⚙ ● ✓ ✗ ⚠). Pure bash, so it gives the same result
# with or without python3 (e.g. in the Docker image).
_display_width() {
    local LC_ALL=C.UTF-8
    local plain ch cp i width=0
    plain="$(_strip_ansi "$1")"

    for ((i = 0; i < ${#plain}; i++)); do
        ch="${plain:i:1}"
        printf -v cp '%d' "'$ch"
        if ((cp < 0x300)); then
            ((width += 1))
        elif (( (cp >= 0x300 && cp <= 0x36F) || (cp >= 0x200B && cp <= 0x200D) ||
                (cp >= 0xFE00 && cp <= 0xFE0F) )); then
            :
        elif (( (cp >= 0x1100 && cp <= 0x115F) || (cp >= 0x2E80 && cp <= 0xA4CF) ||
                (cp >= 0xAC00 && cp <= 0xD7A3) || (cp >= 0xF900 && cp <= 0xFAFF) ||
                (cp >= 0xFE30 && cp <= 0xFE4F) || (cp >= 0xFF00 && cp <= 0xFF60) ||
                (cp >= 0xFFE0 && cp <= 0xFFE6) || (cp >= 0x1F300 && cp <= 0x1F64F) ||
                (cp >= 0x1F680 && cp <= 0x1F6FF) || (cp >= 0x1F900 && cp <= 0x1FAFF) ||
                (cp >= 0x20000 && cp <= 0x3FFFD) )); then
            ((width += 2))
        else
            ((width += 1))
        fi
    done
    printf '%s' "$width"
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
