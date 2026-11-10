#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

client="${1:-}"
[ -n "$client" ] || exit 0

if [ -z "$(list_beacons)" ]; then
    refresh_count
    tmux display-message -c "$client" "beacons: none"
    exit 0
fi

session=$(tmux list-clients -f "#{==:#{client_name},$client}" -F '#{client_session}')
[ -n "$session" ] || exit 0
tmux new-window -t "$session:" -n beacons "'$CURRENT_DIR/menu.sh' '$client'"
