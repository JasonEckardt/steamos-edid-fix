#!/bin/bash
CONN="${CONN:-DP-1}"
EDID=/opt/edid/xb270h.edid
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
for i in $(seq 60); do
  for s in /sys/class/drm/card*-"$CONN"; do
    [ -e "$s/status" ] || continue
    n=${s##*/card}; n=${n%%-*}
    f=/sys/kernel/debug/dri/$n/$CONN/edid_override
    [ -e "$f" ] || continue
    cat "$EDID" > "$f" || exit 1
    echo on     > "$s/status"
    echo detect > "$s/status"
    exit 0
  done
  sleep 1
done
echo "connector $CONN not found" >&2
exit 1
