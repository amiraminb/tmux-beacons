#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

if [ "${1:-}" = "--all" ]; then
    list_beacons | cut -f2 | while read -r pane; do
        tmux set-option -pu -t "$pane" @beacon
    done
    refresh_count
    exit 0
fi

pane="${1:-${TMUX_PANE:-}}"
[ -n "$pane" ] && [ -n "${TMUX:-}" ] || exit 0

[ -n "$(tmux show-option -pqv -t "$pane" @beacon 2>/dev/null)" ] || exit 0
tmux set-option -pu -t "$pane" @beacon
refresh_count
