# Files client on Arch

The package lists install `freefilesync-bin` from AUR and `tailscale`, `openssh`, `python`, and `rbw` from Arch.
Review the AUR build recipe before installation.
This module installs the common Linux units and enables the Tailscale daemon.
It does not sign in, enroll a Files profile, or enable synchronization.

Run the normal Arch installer, then complete `~/dotfiles-linux/files/auth`.
See `~/dotfiles-linux/docs/ftpu-files.md` for the full procedure.

FreeFileSync batch jobs still require a desktop session.
The Files timer belongs to the graphical session and remains disabled until explicitly enabled.
The ARM Pi runs only the existing SFTP server and history jobs.
