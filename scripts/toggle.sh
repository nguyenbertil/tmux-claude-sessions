#!/usr/bin/env bash
# Usage: toggle.sh <client-tty>        turn the sidebar on or off for this client (terminal)
#        toggle.sh focus <client-tty>  turn the sidebar on for this client and move focus to it

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/helpers.sh"

mode=toggle
focus=$(get_option @claude-sessions-focus on)
if [ "$1" = focus ]; then
	mode=focus
	focus=on
	shift
fi
client="${1:-$(tmux display-message -p '#{client_tty}')}"

on=" $(tmux show-option -gqv @claude_sessions_clients) "
case "$on" in
*" $client "*)
	if [ "$mode" = toggle ]; then
		tmux set-option -g @claude_sessions_clients "${on/ $client / }"
		exec "$DIR/sync.sh"
	fi
	;;
*)
	tmux set-option -g @claude_sessions_clients "$on$client "
	;;
esac

"$DIR/sync.sh"

if [ "$focus" = on ]; then
	# Not display-message -c: it reads the formats of the most recent client, not of this one.
	window=$(tmux list-clients -F '#{client_tty} #{window_id}' | awk -v c="$client" '$1 == c { print $2 }')
	sidebar=$(tmux list-panes -t "$window" -F '#{@claude_sessions_sidebar} #{pane_id}' |
		awk '$1 == "1" { print $2; exit }')
	[ -z "$sidebar" ] || tmux select-pane -t "$sidebar"
fi
