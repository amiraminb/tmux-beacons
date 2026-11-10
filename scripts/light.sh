#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

label="${1:-done}"
pane="${TMUX_PANE:-}"

[ -n "$pane" ] && [ -n "${TMUX:-}" ] || exit 0

visible=$(tmux display-message -p -t "$pane" \
    '#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}' 2>/dev/null) || exit 0
[ "$visible" = "1" ] && exit 0

tmux set-option -p -t "$pane" @beacon "$(date +%s)|$label"
refresh_count
