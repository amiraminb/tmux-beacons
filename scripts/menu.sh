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
    local now beacon pane session index window title label epoch color i
    local panes=() labels=() sessions=() indexes=() windows=() titles=() ages=()
    local w_label=0 w_session=0 w_index=0 w_window=0 w_title=0 w_age=0
    now=$(date +%s)

    while IFS="$TAB" read -r beacon pane session index window title; do
        epoch="${beacon%%|*}"
        label="${beacon#*|}"
        session="[$session]"
        title=$(claude_name "$title")
        panes+=("$pane")
        labels+=("$label")
        sessions+=("$session")
        indexes+=("$index")
        windows+=("$window")
        titles+=("$title")
        ages+=("$(age $((now - epoch)))")
        [ "${#label}" -gt "$w_label" ] && w_label=${#label}
        [ "${#session}" -gt "$w_session" ] && w_session=${#session}
        [ "${#index}" -gt "$w_index" ] && w_index=${#index}
        [ "${#window}" -gt "$w_window" ] && w_window=${#window}
        [ "${#title}" -gt "$w_title" ] && w_title=${#title}
        [ "${#ages[${#ages[@]}-1]}" -gt "$w_age" ] && w_age=${#ages[${#ages[@]}-1]}
    done < <(list_beacons)

    for i in "${!panes[@]}"; do
        case "${labels[$i]}" in
            permission) color=31 ;;
            question) color=33 ;;
            *) color=32 ;;
        esac
        printf '%s\t\033[%sm●\033[0m \033[%s;2m%s\033[0m  \033[1m%s\033[0m  \033[2m%s.\033[0m%s  \033[36m%s\033[0m  \033[2m%s\033[0m\n' \
            "${panes[$i]}" "$color" "$color" "$(pad "${labels[$i]}" "$w_label")" \
            "$(pad "${sessions[$i]}" "$w_session")" \
            "$(pad_left "${indexes[$i]}" "$w_index")" "$(pad "${windows[$i]}" "$w_window")" \
            "$(pad "${titles[$i]}" "$w_title")" "$(pad_left "${ages[$i]}" "$w_age")"
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

selected=$(render | fzf --ansi --no-sort --reverse --no-multi \
    --delimiter="$TAB" --with-nth=2.. \
    --info=inline-right --no-separator --no-scrollbar \
    --prompt='› ' --pointer='▌' \
    --color='prompt:cyan,pointer:cyan,header:dim,info:dim,hl:yellow,hl+:yellow' \
    --header='enter jump · ctrl-x clear · ctrl-r clear all · esc close' \
    --bind "ctrl-x:execute-silent('$CURRENT_DIR/clear.sh' {1})+reload('$SELF' --list)" \
    --bind "ctrl-r:execute-silent('$CURRENT_DIR/clear.sh' --all)+reload('$SELF' --list)" |
    cut -f1)

[ -n "$selected" ] && exec "$CURRENT_DIR/jump.sh" "$selected" "$client"
