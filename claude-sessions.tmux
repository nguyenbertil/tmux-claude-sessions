#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$DIR/scripts"

key=$(tmux show-option -gqv @claude-sessions-key)
tmux bind-key "${key:-C-c}" run-shell "'$SCRIPTS/toggle.sh' '#{pane_id}'"

# A fixed array index, so a config reload replaces the hook and keeps hooks from other plugins.
tmux set-hook -g 'session-window-changed[87]' "run-shell \"'$SCRIPTS/follow.sh' '#{window_id}'\""
tmux set-hook -g 'client-session-changed[87]' "run-shell \"'$SCRIPTS/follow.sh' '#{window_id}'\""
