#!/usr/bin/env bash
# Usage: set-state.sh <working|idle|needs-input|end>

cat >/dev/null
[ -n "$TMUX_PANE" ] || exit 0

if [ "$1" = end ]; then
	tmux set-option -pu -t "$TMUX_PANE" @claude_state \; \
		set-option -pu -t "$TMUX_PANE" @claude_state_since 2>/dev/null
	exit 0
fi

# PreToolUse fires on every tool call. Keep the time of the first change,
# because the sidebar sorts on how long a session is in its state.
current=$(tmux display-message -p -t "$TMUX_PANE" '#{@claude_state}' 2>/dev/null)
[ "$current" != "$1" ] || exit 0

tmux set-option -p -t "$TMUX_PANE" @claude_state "$1" \; \
	set-option -p -t "$TMUX_PANE" @claude_state_since "$(date +%s)" 2>/dev/null
exit 0
