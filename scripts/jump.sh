#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

pane="${1:-}"
client="${2:-}"

[ -n "$pane" ] || pane=$(list_beacons | head -n 1 | cut -f2)

if [ -z "$pane" ]; then
    tmux display-message ${client:+-c "$client"} "beacons: none"
    exit 0
fi

if ! tmux display-message -p -t "$pane" '' >/dev/null 2>&1; then
    refresh_count
    tmux display-message ${client:+-c "$client"} "beacons: pane $pane no longer exists"
    exit 0
fi

tmux switch-client ${client:+-c "$client"} -t "$pane"
tmux select-window -t "$pane"
tmux select-pane -t "$pane"
"$CURRENT_DIR/clear.sh" "$pane"
