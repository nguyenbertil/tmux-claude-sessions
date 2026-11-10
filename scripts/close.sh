#!/usr/bin/env bash
# Usage: close.sh <pane-id>
# Kills the window when only a sidebar would stay in it: a lone sidebar fills the whole window.

pane="$1"
# display-message exits 0 with empty output when the pane is gone.
window=$(tmux display-message -p -t "$pane" '#{window_id}' 2>/dev/null)
[ -n "$window" ] || exit 0

# The pane id comes first: an empty sidebar option would shift the awk fields.
others=$(tmux list-panes -t "$window" -F '#{pane_id} #{@claude_sessions_sidebar}' |
	awk -v p="$pane" '$1 != p && $2 != "1"' | wc -l)

if [ "$others" -eq 0 ]; then
	tmux kill-window -t "$window"
else
	tmux kill-pane -t "$pane"
fi
