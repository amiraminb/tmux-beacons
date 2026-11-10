#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

export LC_ALL="${LC_ALL:-en_US.UTF-8}"

SELF="$CURRENT_DIR/menu.sh"
TAB=$'\t'
TITLE_MAX=50

age() {
    local secs=$1
    if [ "$secs" -lt 60 ]; then
        echo "${secs}s"
    elif [ "$secs" -lt 3600 ]; then
        echo "$((secs / 60))m"
    elif [ "$secs" -lt 86400 ]; then
        echo "$((secs / 3600))h"
    else
        echo "$((secs / 86400))d"
    fi
}

# Claude sets the pane title to "<status glyph> <session name>", and to
# "Claude Code" when the session has no name.
claude_name() {
    local title="$1"
    if [[ "$title" =~ ^[^[:alnum:][:space:]]+[[:space:]]+(.*)$ ]]; then
        title="${BASH_REMATCH[1]}"
    fi
    [ "$title" = "Claude Code" ] && title=""
    if [ "${#title}" -gt "$TITLE_MAX" ]; then
        title="${title:0:$((TITLE_MAX - 1))}…"
    fi
    echo "$title"
}

pad() {
    printf '%s%*s' "$1" $(($2 - ${#1})) ''
}

pad_left() {
    printf '%*s%s' $(($2 - ${#1})) '' "$1"
}

render() {
    local now beacon pane session index window title label epoch color i plain name
    local panes=() names=() plains=() labels=() ages=()
    local w_name=0 w_label=0 w_age=0
    now=$(date +%s)

    while IFS="$TAB" read -r beacon pane session index window title; do
        epoch="${beacon%%|*}"
        label="${beacon#*|}"
        title=$(claude_name "$title")
        plain="[$session]$window"
        name="\033[1m[$session]\033[0m$window"
        if [ -n "$title" ]; then
            plain="$plain : $title"
            name="$name\033[2m : \033[0m\033[36m$title\033[0m"
        fi
        panes+=("$pane")
        names+=("$name")
        plains+=("$plain")
        labels+=("$label")
        ages+=("$(age $((now - epoch)))")
        [ "${#plain}" -gt "$w_name" ] && w_name=${#plain}
        [ "${#label}" -gt "$w_label" ] && w_label=${#label}
        [ "${#ages[${#ages[@]}-1]}" -gt "$w_age" ] && w_age=${#ages[${#ages[@]}-1]}
    done < <(list_beacons)

    for i in "${!panes[@]}"; do
        case "${labels[$i]}" in
            permission) color=31 ;;
            question) color=33 ;;
            *) color=32 ;;
        esac
        printf '%s\t%b%*s  \033[%sm%s\033[0m  \033[2m%s\033[0m\n' \
            "${panes[$i]}" "${names[$i]}" $((w_name - ${#plains[$i]})) '' \
            "$color" "$(pad "${labels[$i]}" "$w_label")" "$(pad_left "${ages[$i]}" "$w_age")"
    done
}

if [ "${1:-}" = "--list" ]; then
    render
    exit 0
fi

client="${1:-}"

if [ -z "$(list_beacons)" ]; then
    refresh_count
    exit 0
fi

selected=$(render | fzf --ansi --no-sort \
    --delimiter="$TAB" --with-nth=2.. \
    --header='enter: jump | ctrl-x: clear | ctrl-r: clear all | esc: close' \
    --bind "ctrl-x:execute-silent('$CURRENT_DIR/clear.sh' {1})+reload('$SELF' --list)" \
    --bind "ctrl-r:execute-silent('$CURRENT_DIR/clear.sh' --all)+reload('$SELF' --list)" |
    cut -f1)

[ -n "$selected" ] && exec "$CURRENT_DIR/jump.sh" "$selected" "$client"
