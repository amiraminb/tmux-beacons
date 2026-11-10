#!/usr/bin/env bash

get_opt() {
    local value
    value=$(tmux show-option -gqv "$1")
    echo "${value:-$2}"
}

list_beacons() {
    local order sort_flag=""
    order=$(get_opt @beacons-order oldest)
    [ "$order" = "newest" ] && sort_flag="-r"
    tmux list-panes -a -f '#{@beacon}' \
        -F "#{@beacon}	#{pane_id}	#{session_name}	#{window_index}	#{window_name}	#{pane_title}" |
        sort -n $sort_flag
}

refresh_count() {
    local count client
    count=$(tmux list-panes -a -f '#{@beacon}' -F x | wc -l | tr -d ' ')
    tmux set-option -g @beacons_count "$count"
    for client in $(tmux list-clients -F '#{client_name}'); do
        tmux refresh-client -S -t "$client"
    done
}
