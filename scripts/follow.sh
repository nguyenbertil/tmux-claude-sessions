#!/usr/bin/env bash
# tmux runs this from the session-window-changed and client-session-changed hooks.
# Usage: follow.sh <window-id>

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/helpers.sh"

target="$1"
sidebar=$(sidebar_pane)
[ -n "$sidebar" ] && [ -n "$target" ] || exit 0

old=$(tmux display-message -p -t "$sidebar" '#{window_id}')
[ "$old" != "$target" ] || exit 0

save_widths "$target"
tmux join-pane -d -f -h -l "$(sidebar_width)" -s "$sidebar" \
	-t "$(top_right_pane "$target")"
restore_widths "$old"
