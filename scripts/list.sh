#!/usr/bin/env bash
# Output, one line per Claude session, most urgent first:
#   <pane-id> TAB <state> TAB <topic> TAB <session:window>

SHELLS=" bash zsh fish sh dash ksh tcsh nu "
T=$'\t'

# Only panes with a state: read joins empty tab-separated fields, and the columns would shift.
tmux list-panes -a -f '#{@claude_state}' \
	-F "#{pane_id}$T#{@claude_state}$T#{@claude_state_since}$T#{pane_current_command}$T#{session_name}:#{window_index}$T#{pane_current_path}$T#{pane_title}" |
	while IFS="$T" read -r pane state since command location path title; do
		# A shell in the foreground means Claude is gone (crash or kill -9).
		case "$SHELLS" in *" ${command#-} "*) continue ;; esac

		case "$state" in
		needs-input) rank=0 ;;
		idle) rank=1 ;;
		*) rank=2 ;;
		esac

		# Claude sets the title to "<symbol> <topic>". Drop the symbol.
		if [[ "$title" == ?" "* && "${title:0:1}" != [[:alnum:]] ]]; then
			title=${title:2}
		fi
		[ -n "$title" ] || title=$(basename "$path")

		printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$rank" "${since:-0}" "$pane" "$state" "$title" "$location"
	done |
	sort -t "$T" -k1,1n -k2,2n |
	cut -f3-
