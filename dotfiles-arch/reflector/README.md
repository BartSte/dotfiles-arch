# Pacman mirrors

Reflector manages `/etc/pacman.d/mirrorlist` through its packaged systemd service and weekly timer.
The configuration selects HTTPS mirrors that synchronized within the last 12 hours.
It benchmarks up to 30 recent mirrors and keeps up to 10, ordered by download speed.

Install the configuration and activate the timer:

```sh
~/dotfiles-arch/reflector/main
```

The installer requires sudo access. It refreshes the mirrors before it enables the timer.
It saves the original configuration and mirror list with the suffix `.before-reflector`.
Later installations retain these original backups.
The Arch layer installer also runs this module.

Refresh the mirrors manually:

```sh
sudo systemctl start reflector.service
```

Inspect the schedule and most recent run:

```sh
systemctl list-timers reflector.timer
journalctl -u reflector.service -n 30 --no-pager
```

The timer uses the packaged weekly schedule, with a random delay of up to 12 hours.
It also catches up after a missed run. A separate boot service is not necessary.
Mirror refreshes do not update packages.

Edit `reflector.conf` in this directory and run the installer again to change the selection.
