#!/bin/sh
# Warn once per threshold crossing when the battery runs low.
#
# Driven by the battery-notify.timer systemd user unit rather than by
# slstatus, so it costs nothing per status tick. State lives in
# XDG_RUNTIME_DIR so each login starts clean and one low spell produces one
# warning rather than one per timer tick.

BAT=${BATTERY_DEV:-/sys/class/power_supply/BAT0}
WARN=${BATTERY_WARN:-20}
CRIT=${BATTERY_CRIT:-10}
STATE_FILE="${BATTERY_STATE_FILE:-${XDG_RUNTIME_DIR:-/tmp}/battery-notify.state}"
NOTIFY_ID=9001  # fixed id so a repeat warning replaces rather than stacks

[ -r "$BAT/capacity" ] && [ -r "$BAT/status" ] || exit 0

read -r perc < "$BAT/capacity"
read -r state < "$BAT/status"

last=''
[ -r "$STATE_FILE" ] && read -r last < "$STATE_FILE"

if [ "$state" != Discharging ]; then
	# On AC: drop any standing warning and forget the level, so the next
	# discharge down through a threshold warns again.
	[ -n "$last" ] && dunstify -C "$NOTIFY_ID" >/dev/null 2>&1
	rm -f "$STATE_FILE"
	exit 0
fi

if [ "$perc" -le "$CRIT" ]; then
	level=crit
elif [ "$perc" -le "$WARN" ]; then
	level=warn
else
	level=ok
fi

[ "$level" = "$last" ] && exit 0

case "$level" in
	crit)
		dunstify -a battery -r "$NOTIFY_ID" -u critical \
			"Battery critical" "${perc}% remaining — plug in now."
		;;
	warn)
		dunstify -a battery -r "$NOTIFY_ID" -u normal -t 10000 \
			"Battery low" "${perc}% remaining."
		;;
	ok)
		[ -n "$last" ] && dunstify -C "$NOTIFY_ID" >/dev/null 2>&1
		;;
esac

printf '%s\n' "$level" > "$STATE_FILE"
