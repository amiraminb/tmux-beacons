#!/usr/bin/env bash

get_opt() {
    local value
    value=$(tmux show-option -gqv "$1")
    echo "${value:-$2}"
}

list_beacons() {
    local output order rows=""
    output=$(tmux display-message -p '#{@beacons-order}' \; list-panes -a -f '#{@beacon}' \
        -F "#{@beacon}	#{pane_id}	#{session_name}	#{window_index}	#{window_name}	#{pane_title}")
    order="${output%%$'\n'*}"
    [[ "$output" == *$'\n'* ]] && rows="${output#*$'\n'}"
    [ -n "$rows" ] || return 0
    if [ "$order" = "newest" ]; then
        sort -rn <<< "$rows"
    else
        sort -n <<< "$rows"
    fi
}

refresh_count() {
    local count client
    count=$(tmux list-panes -a -f '#{@beacon}' -F x | wc -l | tr -d ' ')
    tmux set-option -g @beacons_count "$count"
    for client in $(tmux list-clients -F '#{client_name}'); do
        tmux refresh-client -S -t "$client"
    done
}

TITLE_MAX=50

# Claude sets the pane title to "<status glyph> <session name>", and to
# "Claude Code" when the session has no name.
claude_name_into() {
    local _name="$2"
    if [[ "$_name" =~ ^[^[:alnum:][:space:]]+[[:space:]]+(.*)$ ]]; then
        _name="${BASH_REMATCH[1]}"
    fi
    [ "$_name" = "Claude Code" ] && _name=""
    if [ "${#_name}" -gt "$TITLE_MAX" ]; then
        _name="${_name:0:$((TITLE_MAX - 1))}…"
    fi
    printf -v "$1" '%s' "$_name"
}
