#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

selected=""
cursor=0
offset=0
panes=()

# Ctrl-C would end the sidebar without the width restore that toggle.sh does.
trap '' INT
trap 'printf "\e[?25h"; stty echo 2>/dev/null' EXIT
stty -echo
printf '\e[?25l'

render() {
	local cols rows text_width i line row index gutter start end
	local pane state title location head
	local -a out owner

	cols=$(tput cols)
	rows=$(tput lines)
	text_width=$((cols - 4))
	[ "$text_width" -gt 0 ] || text_width=1

	panes=()
	while IFS=$'\t' read -r pane state title location; do
		[ -n "$pane" ] || continue
		i=${#panes[@]}
		panes+=("$pane")
		case "$state" in
		needs-input) head=$'\e[1;31m! needs input\e[0m' ;;
		idle) head=$'\e[32m● idle\e[0m' ;;
		*) head=$'\e[2m◌ working\e[0m' ;;
		esac
		out+=("$head")
		owner+=("$i")
		while IFS= read -r line; do
			out+=("  $line")
			owner+=("$i")
		done < <(printf '%s\n' "$title" | fold -s -w "$text_width")
		out+=($'  \e[2m'"${location:0:$text_width}"$'\e[0m')
		owner+=("$i")
		out+=("")
		owner+=(-1)
	done < <("$DIR/list.sh")

	if [ ${#panes[@]} -eq 0 ]; then
		selected=""
		printf '\e[H\e[2J\e[2mNo Claude sessions\e[0m'
		return
	fi

	for i in "${!panes[@]}"; do
		if [ "${panes[$i]}" = "$selected" ]; then
			cursor=$i
			break
		fi
	done
	[ "$cursor" -lt ${#panes[@]} ] || cursor=$((${#panes[@]} - 1))
	selected=${panes[$cursor]}

	start=-1
	end=-1
	for i in "${!owner[@]}"; do
		if [ "${owner[$i]}" = "$cursor" ]; then
			[ "$start" -ge 0 ] || start=$i
			end=$i
		fi
	done
	[ "$end" -lt $((offset + rows)) ] || offset=$((end - rows + 1))
	[ "$start" -ge "$offset" ] || offset=$start

	printf '\e[H'
	for ((row = 0; row < rows; row++)); do
		index=$((offset + row))
		gutter="  "
		if [ "$index" -lt ${#out[@]} ] && [ "${owner[$index]}" = "$cursor" ]; then
			gutter=$'\e[36m▌\e[0m '
		fi
		[ "$index" -lt ${#out[@]} ] && line=${out[$index]} || line=""
		[ -n "$line" ] || gutter="  "
		printf '%s%s\e[K' "$gutter" "$line"
		[ "$row" -eq $((rows - 1)) ] || printf '\n'
	done
}

move() {
	[ ${#panes[@]} -gt 0 ] || return
	cursor=$((cursor + $1))
	[ "$cursor" -ge 0 ] || cursor=0
	[ "$cursor" -lt ${#panes[@]} ] || cursor=$((${#panes[@]} - 1))
	selected=${panes[$cursor]}
}

while true; do
	render
	if IFS= read -rsn1 -t 1 key; then
		case "$key" in
		j) move 1 ;;
		k) move -1 ;;
		"") [ -z "$selected" ] || "$DIR/jump.sh" "$selected" ;;
		$'\e')
			IFS= read -rsn2 -t 1 rest
			case "$rest" in
			"[A") move -1 ;;
			"[B") move 1 ;;
			esac
			;;
		esac
	fi
done
