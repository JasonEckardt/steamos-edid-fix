# SteamOS EDID Fix

Workaround for the *Acer XB270H* on DisplayPort to display the correct native resolution 1920x1080 @ 144 Hz. 

The AI's guess is that the monitor's G-SYNC module doesn't return an EDID to non-NVIDIA GPUs, so SteamOS falls back to 640x480.

## Installation (as root)

Install this repo to `/opt/edid/`.

You can install it somewhere else like `/etc/edid/` dir, just change `EDID` value in apply.sh and `ExecStart` in edid.service.

`xb270h.edid` must be the raw 256-byte binary (`wc -c`), not a hex dump.

```sh
xxd -r -p xb270h.hex xb270h.edid
wc -c xb270h.edid
```

`CONN` in apply.sh is the bare connector name (default `DP-1`). Find yours with `ls /sys/kernel/debug/dri/*/ | grep DP`.

> Run `./apply.sh` to apply the EDID before adding it as a service, then check `cat /sys/class/drm/card*-DP-1/modes` lists 1920x1080.

## EDID Service

This service reapplies EDID every time the system boots.

### Install service

```sh
cp edid.service /etc/systemd/system/edid.service
```

### Enable service

```sh
systemctl daemon-reload
systemctl enable --now edid.service
```

If the filesystem is read-only, run `steamos-readonly disable` first and `steamos-readonly enable` after.

## Notes

- The override applies to whatever is plugged into that connector. To undo it, disable the service `sudo systemctl disable --now edid.service` and reboot.
- Pick 1920x1080 144 Hz in display settings in KDE System Settings > Display & Monitor > Display Configuration.
- Don't expect GSYNC to work.
- Not yet tested across a SteamOS update. If `/opt/edid` disappears, reinstall it in another directory, maybe `/etc/` survices updates?
