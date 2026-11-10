#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"
source "$SCRIPTS_DIR/helpers.sh"

key=$(get_opt @beacons-key b)
jump_key=$(get_opt @beacons-jump-key B)
index=$(get_opt @beacons-hook-index 42)

tmux bind-key "$key" if-shell -F '#{@beacons_count}' \
    "new-window -n beacons \"'$SCRIPTS_DIR/menu.sh'\"" \
    "display-message 'beacons: none'"
tmux bind-key "$jump_key" run-shell -b "'$SCRIPTS_DIR/jump.sh' '' '#{client_name}'"

# Indexed hooks: an unindexed `set-hook -g` replaces every entry of that hook,
# including ones other plugins registered.
tmux set-hook -g "pane-focus-in[$index]" \
    "if-shell -F '#{@beacon}' \"run-shell -b \\\"'$SCRIPTS_DIR/clear.sh' '#{pane_id}'\\\"\""
for hook in pane-exited after-kill-pane window-unlinked session-closed; do
    tmux set-hook -g "$hook[$index]" \
        "if-shell -F '#{@beacons_count}' \"run-shell -b \\\"'$SCRIPTS_DIR/count.sh'\\\"\""
done

refresh_count
