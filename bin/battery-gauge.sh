#!/bin/sh
# Render the battery as a block gauge on a single line, for slstatus.
#
#   BAT [########..] 80%     discharging
#   BAT [########..] 80%+    charging
#   BAT [##........] 18% !!  discharging at or below LOW
#
# The "!!" marker exists because dwm draws the whole status string with one
# colour scheme (see drawbar() in dwm.c) and cannot highlight a substring
# without the status2d patch. Uses shell builtins only: slstatus calls this
# once per tick via popen().

BAT=${BATTERY_DEV:-/sys/class/power_supply/BAT0}
CELLS=${BATTERY_CELLS:-10}
LOW=${BATTERY_LOW:-20}

FULL_CELL='█'
EMPTY_CELL='░'

if [ ! -r "$BAT/capacity" ] || [ ! -r "$BAT/status" ]; then
	printf 'BAT n/a'
	exit 0
fi

read -r perc < "$BAT/capacity"
read -r state < "$BAT/status"

# Round to nearest cell rather than truncating, so 95% shows as full.
filled=$(( (perc * CELLS + 50) / 100 ))
[ "$filled" -lt 0 ] && filled=0
[ "$filled" -gt "$CELLS" ] && filled=$CELLS

gauge=''
i=0
while [ "$i" -lt "$CELLS" ]; do
	if [ "$i" -lt "$filled" ]; then
		gauge="$gauge$FULL_CELL"
	else
		gauge="$gauge$EMPTY_CELL"
	fi
	i=$(( i + 1 ))
done

case "$state" in
	Charging) suffix='+' ;;
	Full)     suffix='o' ;;
	*)        suffix='' ;;
esac

if [ "$state" = Discharging ] && [ "$perc" -le "$LOW" ]; then
	suffix=' !!'
fi

printf 'BAT [%s] %s%%%s' "$gauge" "$perc" "$suffix"
