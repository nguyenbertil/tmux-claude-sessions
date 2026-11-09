#!/usr/bin/env bash
# Usage: jump.sh <pane-id>

pane="$1"
target=$(tmux display-message -p -t "$pane" '#{session_id} #{window_id}') || exit 0
session=${target% *}
window=${target#* }

tmux switch-client -t "$session" \; select-window -t "$window" \; select-pane -t "$pane"
