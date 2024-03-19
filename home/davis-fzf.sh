#!/bin/sh

set -eu

TAGS=" artist album genre composer work "

expr_reduce() {
	awk -vFS="\n" 'NR > 1 { printf(" AND ") } { printf "%s", $1 }'
}

escape_quotes() {
	sed 's/"/\\\"/g'
}

alternatives() {
	EXPR="$1"
	TAG="$2"

	if [ -n "$EXPR" ]; then
		davis list "$TAG" "($EXPR)"
	else
		davis list "$TAG"
	fi
}

foo() {
	EXPR="${1:-}"
	LAST="${2-}"
	echo "$EXPR"
	case "$TAGS" in
		*" $LAST "*)
			NEW_TERMS="$(alternatives "$EXPR" "$LAST" | sk -m | escape_quotes | while read -r l; do echo "($LAST == \"$l\")"; done | expr_reduce)"
			if [ -n "$EXPR" ]; then
				EXPR="$EXPR AND $NEW_TERMS"
			else
				EXPR="$NEW_TERMS"
			fi
			foo "$EXPR"
			;;
		*)
			SELECTED="$(echo "$TAGS path" | tr ' ' '\n' | grep -v '^$' | sk)" || return 0
			foo "$EXPR" "$SELECTED"
			;;
	esac
}

EXPR="$(foo | tail -n 1)"
if [ -n "$EXPR" ]; then
	davis clear
	davis search "($EXPR)" | rev | cut -d/ -f2- | rev | sort -u | xargs -L1 -d'\n' davis add
	davis play
fi

