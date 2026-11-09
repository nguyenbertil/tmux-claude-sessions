#!/usr/bin/env bash
# Usage: toggle.sh <pane-id>
#        toggle.sh close

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/helpers.sh"

close_sidebar() {
	local window
	window=$(tmux display-message -p -t "$1" '#{window_id}')
	tmux kill-pane -t "$1"
	restore_widths "$window"
}

open_sidebar() {
	local window pane focus_flag
	window=$(tmux display-message -p -t "$1" '#{window_id}')
	save_widths "$window"
	focus_flag=""
	[ "$(get_option @claude-sessions-focus on)" = on ] || focus_flag="-d"
	pane=$(tmux split-window $focus_flag -f -h -l "$(sidebar_width)" -t "$(top_right_pane "$window")" \
		-P -F '#{pane_id}' "'$DIR/sidebar.sh'")
	tmux set-option -p -t "$pane" @claude_sessions_sidebar 1
}

sidebar=$(sidebar_pane)
if [ -n "$sidebar" ]; then
	close_sidebar "$sidebar"
elif [ "$1" != close ]; then
	open_sidebar "${1:-$(tmux display-message -p '#{pane_id}')}"
fi
