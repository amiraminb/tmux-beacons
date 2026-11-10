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

if ! tmux switch-client ${client:+-c "$client"} -t "$pane" \; \
    select-window -t "$pane" \; \
    select-pane -t "$pane" \; \
    set-option -pu -t "$pane" @beacon 2>/dev/null; then
    tmux display-message ${client:+-c "$client"} "beacons: pane $pane no longer exists"
fi

refresh_count
