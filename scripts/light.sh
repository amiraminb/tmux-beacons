#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

export LC_ALL="${LC_ALL:-en_US.UTF-8}"

label="${1:-done}"
pane="${TMUX_PANE:-}"

[ -n "$pane" ] && [ -n "${TMUX:-}" ] || exit 0

SEP=$'\x1f'
info=$(tmux display-message -p -t "$pane" \
    "#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}$SEP#{session_name}$SEP#{window_name}$SEP#{pane_title}$SEP#{@beacons-toast}$SEP#{@beacons-toast-duration}" \
    2>/dev/null) || exit 0
IFS="$SEP" read -r visible session window title toast duration <<< "$info"
[ "$visible" = "1" ] && exit 0

tmux set-option -p -t "$pane" @beacon "$(date +%s)|$label"
refresh_count

[ "${toast:-on}" = "off" ] && exit 0

claude_name_into title "$title"
message="beacon: [$session]$window"
[ -n "$title" ] && message="$message : $title"
message="$message ($label)"

# display-message expands formats, so a literal # must be doubled.
message="${message//#/##}"
for client in $(tmux list-clients -F '#{client_name}'); do
    tmux display-message -c "$client" -d "${duration:-4000}" "$message"
done
