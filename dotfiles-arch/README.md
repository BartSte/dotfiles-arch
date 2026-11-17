# Arch Linux dotfiles

This layer contains Arch package lists, Sway, Waybar, DNS, firewall rules, and systemd units.
Use it with the base and Linux layers.
See the [base overview](https://github.com/BartSte/dotfiles/blob/master/README.md) for installation and common tools.

## Arch layer (dotfiles-arch)

Arch‑specific modules (pacman/aur, sway/waybar/kmonad, DNS/firewall, VPN, systemd units).  
Also contains **mutt**, **khal**, and **khalorg**.

---

## VPN (Arch layer)

VPN service: **Proton VPN CLI** (`proton-vpn-cli`).

---

## Local calendars

The calendar user timer runs `mycalsync --verbose` five minutes after each completed cycle.
It connects directly to Outlook and exports Org agendas under `~/.local/share/khalorg/agendas/`.
Working documents and notes synchronize through `~/Files` over SFTP and Tailscale.
See the [base calendar guide](https://github.com/BartSte/dotfiles/blob/master/README.md#calendar-setup).

The base repository owns `~/README.md`. This layer owns `dotfiles-arch/README.md`.

## Shared Files

FreeFileSync synchronizes `~/Files` through SFTP over Tailscale.
Batch jobs use Xvfb without a desktop window. `ftpu-files preview` remains interactive.
The package list includes `xorg-server-xvfb` and `xorg-xauth` for batch jobs.

Deletion propagation defaults to off. Enable it with `ftpu-files deletions on` after checking your backup and synchronized copies.
Deleted and overwritten copies remain under `~/.local/state/ftpu-files/versions`.
`ftpu-files deletions off` stops future deletion propagation.
Android's active Files pair needs the matching **Sync deletions** setting before it resumes.
Keep the camera and WhatsApp backup settings separate.

See the [Linux Files guide](https://github.com/BartSte/dotfiles-linux/blob/master/dotfiles-linux/docs/ftpu-files.md) for scheduling, conflicts, and recovery.

## Pacman mirrors

Reflector refreshes the mirror list through its packaged weekly timer.
Run `~/dotfiles-arch/reflector/main` to install the configuration and activate it.
See the [mirror guide](reflector/README.md) for selection rules and manual refresh commands.

_Codex (AI) for Bart._
