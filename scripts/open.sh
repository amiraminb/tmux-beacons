#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

export LC_ALL="${LC_ALL:-en_US.UTF-8}"

HEADER='enter jump · ctrl-x clear · ctrl-r clear all · esc close'

client="${1:-}"
[ -n "$client" ] || exit 0

rows=$("$CURRENT_DIR/menu.sh" --list)
if [ -z "$rows" ]; then
    refresh_count
    tmux display-message -c "$client" "beacons: none"
    exit 0
fi

count=0
longest=${#HEADER}
while IFS= read -r row; do
    row=$(printf '%s' "${row#*$'\t'}" | sed $'s/\033\\[[0-9;]*m//g')
    [ "${#row}" -gt "$longest" ] && longest=${#row}
    count=$((count + 1))
done <<< "$rows"

client_width=$(tmux display-message -p -c "$client" '#{client_width}')
client_height=$(tmux display-message -p -c "$client" '#{client_height}')
width=$((longest + 6))
height=$((count + 4))
[ "$width" -gt $((client_width - 4)) ] && width=$((client_width - 4))
[ "$height" -gt $((client_height - 4)) ] && height=$((client_height - 4))

# display-popup does not expand formats in its command, so the client name is
# resolved here and passed on as a literal argument.
tmux display-popup -c "$client" -E -w "$width" -h "$height" -T " beacons · $count " \
    "'$CURRENT_DIR/menu.sh' '$client'"
