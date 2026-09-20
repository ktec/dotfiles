#!/bin/bash
DIR="$HOME/Pictures/Screenshots/"
mkdir -p "$DIR"

case "$1" in
  quick) xfce4-screenshooter -r -s "$DIR" && notify-send "📸 Saved to $DIR" ;;
  gui)   xfce4-screenshooter ;;
esac