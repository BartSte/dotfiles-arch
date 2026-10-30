# Daily maintenance

This module installs daily updates for Arch Linux and Arch on WSL.
It runs official package updates first. Then it runs AUR and Neovim updates
as the selected user. Codex updates remain manual.

The module is part of `~/dotfiles-arch/systemd/main`.
You can install it separately without running the other dotfiles modules.

## Install

Install the news checker through a full system upgrade:

```sh
sudo pacman -Syu --needed informant &&
sudo informant read &&
~/dotfiles-arch/systemd/maintenance/main
```

The commands read and acknowledge the current Arch news before installation.
Each step runs only if the previous step succeeds.

The installer needs sudo once. It copies scripts and units into root-owned
locations. It does not explicitly start a package or plugin update.
If an existing timer has a missed run, enabling it can trigger that run.
The standard Arch package list also includes `informant` for new machines.

The installer enables `dotfiles-user-update@USER.timer` at 02:00 local time,
with a random delay of up to 15 minutes. Missed runs execute when the timer
becomes active again. The timer does not start WSL or wake the laptop.

## Update sequence

1. `dotfiles-package-update.service` runs `informant check` as root.
2. If no unread news exists, it runs `pacman -Syu --noconfirm`.
3. It lists `.pacnew` and `.pacsave` files and the installed kernel versions.
4. `dotfiles-user-update@USER.service` runs AUR updates through `yay -Sua`.
5. The same service runs a headless Lazy update, including plugin build hooks.

A package-update failure blocks the dependent user service. An AUR failure
does not prevent the Neovim step. Each step reports its result in the journal.
Lazy task errors produce a failed service instead of a false success.

Source builds are enabled. The user job uses two build threads by default,
low CPU priority, and idle I/O scheduling. It retains build dependencies
instead of removing packages automatically. Unknown pacman options, missing
keys, conflicts, and transaction failures require manual attention.

The services have no automatic runtime cutoff. This prevents a timer timeout
from interrupting an active package transaction. A shutdown can wait for an
active job to finish. The timer does not start a second copy of a running job.
File locks also reject overlapping script runs. Existing pacman locks are
never removed automatically.

## Privileges

AUR builds run as your normal user. Package installation requires root.
The installer adds `/etc/sudoers.d/zz-dotfiles-maintenance-USER`, which permits
passwordless execution of one root-owned helper, `aur-pacman`.

The helper accepts package installation and dependency-reason operations.
It rejects alternate configurations, roots, hook directories, package removals,
and overwrite options. It does not grant passwordless shell commands or replace
`/etc/sudoers`.

Package installation can execute package scripts as root. Treat this account
as trusted to install system packages. AUR build scripts can execute code as
the user. This automation does not review AUR recipe changes for you.

The main sudoers policy must include `/etc/sudoers.d`, or already permit the
helper. The installer tests the exact helper command before enabling the timer.
The `zz-` prefix places the rule after the common `wheel` policy. Sudo applies
the last matching rule. The installer removes its older, unprefixed rule.
It does not unlock an immutable sudoers file or change the existing lock policy.

## Status and manual runs

```sh
dotfiles-update-status
sudo journalctl -u dotfiles-package-update -u "dotfiles-user-update@$USER"
```

Start the complete update sequence manually:

```sh
sudo systemctl start "dotfiles-user-update@$USER.service"
```

After a failure, resolve the reported problem and start the service again.
If unread news blocks the update, run `sudo informant read` first.

Review `.pacnew` files manually. Restart programs after their updates.
Reboot manually when the kernel or other system updates require it.
For WSL kernel updates, use the Windows/WSL maintenance tools separately.

## Package download errors

If several mirrors return HTTP 404 for a package, the local database can refer
to a package version that the mirrors no longer serve. Refresh the mirrors,
then force a database refresh as part of a full upgrade:

```sh
sudo cp -a /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.before-maintenance &&
sudo reflector --country Germany,Netherlands --protocol https --age 12 --latest 20 \
    --sort score --save /etc/pacman.d/mirrorlist &&
sudo pacman -Syyu --needed informant &&
sudo informant read &&
~/dotfiles-arch/systemd/maintenance/main
```

Select nearby countries for other locations. Use `-Syyu` for this repair;
normal daily updates use `-Syu`. Do not refresh the database without completing
the full upgrade. The scheduled jobs report download failures for manual repair.

The user job saves its most recent AUR and Neovim results under
`~/.local/state/dotfiles-maintenance`. If you set `XDG_STATE_HOME`, it uses that
directory instead. System services do not load interactive shell aliases.

Neovim uses the normal configuration and updates its local Lazy lockfile.
This module does not commit, push, or distribute lockfile changes.

## Change the schedule or build parallelism

Use a timer override, then reload systemd and restart the timer:

```sh
sudo systemctl edit "dotfiles-user-update@$USER.timer"
```

```ini
[Timer]
OnCalendar=
OnCalendar=*-*-* 07:00:00
```

```sh
sudo systemctl daemon-reload
sudo systemctl restart "dotfiles-user-update@$USER.timer"
```

Use a service override to change build parallelism:

```sh
sudo systemctl edit "dotfiles-user-update@$USER.service"
```

```ini
[Service]
Environment=MAKEFLAGS=-j4
```

## Disable

```sh
sudo systemctl disable --now "dotfiles-user-update@$USER.timer"
```

This stops future scheduled runs. It does not interrupt an active update.
To remove the helper's sudo permission, remove the matching
`/etc/sudoers.d/zz-dotfiles-maintenance-USER` file with sudo.

## Validation

These tests use temporary files and fake update tools. They do not update the
system or Neovim plugins:

```sh
bash ~/dotfiles-arch/systemd/maintenance/tests/test_maintenance.sh
nvim --headless -u NONE -l ~/dotfiles-arch/systemd/maintenance/tests/test_lazy_update.lua
```
