#!/usr/bin/env bash

get_option() {
	local value
	value=$(tmux show-option -gqv "$1")
	printf '%s' "${value:-$2}"
}

sidebar_width() {
	get_option @claude-sessions-width 32
}

save_widths() {
	tmux set-option -w -t "$1" @claude_sessions_widths \
		"$(tmux list-panes -t "$1" -F '#{pane_id}:#{pane_width}' | tr '\n' ' ')"
}

# Panes created after the save keep sharing space with the pane they split from.
restore_widths() {
	local saved entry pass
	saved=$(tmux show-option -wqv -t "$1" @claude_sessions_widths)
	[ -n "$saved" ] || return 0
	tmux set-option -wu -t "$1" @claude_sessions_widths
	# A resize can push a neighbour that was already restored, so do two passes.
	for pass in 1 2; do
		for entry in $saved; do
			tmux resize-pane -t "${entry%%:*}" -x "${entry#*:}" 2>/dev/null
		done
	done
}

# join-pane -f puts the pane next to its target, not at the window edge.
top_right_pane() {
	tmux list-panes -t "$1" -F '#{pane_at_right}#{pane_at_top} #{pane_id}' |
		awk '$1 == "11" { print $2; exit }'
}
