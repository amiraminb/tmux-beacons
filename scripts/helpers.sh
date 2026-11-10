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
