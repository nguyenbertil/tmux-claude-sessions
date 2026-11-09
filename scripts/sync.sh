#!/usr/bin/env bash
# Puts exactly one sidebar in the current window of each client (terminal) that has the sidebar on.
# Clients that show the same window share its sidebar. tmux runs this from hooks when a client
# changes window or session, or detaches.
# Usage: sync.sh [<client-tty that detaches>]

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/helpers.sh"

gone="$1"
on=" $(tmux show-option -gqv @claude_sessions_clients) "

kept=""
wanted=" "
while read -r tty window; do
	[ "$tty" != "$gone" ] || continue
	case "$on" in *" $tty "*) ;; *) continue ;; esac
	kept="$kept$tty "
	case "$wanted" in *" $window "*) ;; *) wanted="$wanted$window " ;; esac
done < <(tmux list-clients -F '#{client_tty} #{window_id}')
tmux set-option -g @claude_sessions_clients "$kept"

have=" "
spare=""
while read -r pane window; do
	case "$wanted" in
	*" $window "*)
		case "$have" in
		*" $window "*) spare="$spare$pane " ;;
		*) have="$have$window " ;;
		esac
		;;
	*) spare="$spare$pane " ;;
	esac
done < <(tmux list-panes -a -F '#{@claude_sessions_sidebar} #{pane_id} #{window_id}' | awk '$1 == "1" { print $2, $3 }')

for window in $wanted; do
	case "$have" in *" $window "*) continue ;; esac
	save_widths "$window"
	if [ -n "$spare" ]; then
		# Move a sidebar that is not needed any more, so its cursor stays where it was.
		pane=${spare%% *}
		spare=${spare#* }
		old=$(tmux display-message -p -t "$pane" '#{window_id}')
		tmux join-pane -d -f -h -l "$(sidebar_width)" -s "$pane" -t "$(top_right_pane "$window")"
		restore_widths "$old"
	else
		pane=$(tmux split-window -d -f -h -l "$(sidebar_width)" -t "$(top_right_pane "$window")" \
			-P -F '#{pane_id}' "'$DIR/sidebar.sh'")
		tmux set-option -p -t "$pane" @claude_sessions_sidebar 1
	fi
done

for pane in $spare; do
	old=$(tmux display-message -p -t "$pane" '#{window_id}')
	tmux kill-pane -t "$pane"
	restore_widths "$old"
done
