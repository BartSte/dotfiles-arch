# Dotfiles BartSte

This README is shared across these repositories:

- **BartSte/dotfiles** (base, cross‑platform)
- **BartSte/dotfiles-linux** (Linux common)
- **BartSte/dotfiles-arch** (Arch‑specific)
- **BartSte/dotfiles-pi** (Raspberry Pi / Debian‑based)
- **BartSte/dotfiles-windows** (Windows)

---

## Layered model

- **Base** → `dotfiles`
- **Linux common** → `dotfiles-linux`
- **Linux distro layer** → `dotfiles-arch` **or** `dotfiles-pi`
- **Windows** → `dotfiles-windows`

On Linux, install **base + linux + distro layer**.
On Windows, install **base + windows**.

---

## Linux install (Arch / Pi)

Use the **base** initialize script. It clones base + linux + the appropriate distro layer.

```bash
curl -O https://raw.githubusercontent.com/BartSte/dotfiles/master/dotfiles/initialize && bash ./initialize; rm ./initialize
```

Then:

```bash
~/dotfiles-linux/main
# Arch:
~/dotfiles-arch/main
# or Raspberry Pi:
~/dotfiles-pi/main
```

Finish by setting `~/.dotfiles_config.sh`:

```bash
export BWEMAIL=
export MICROSOFT_ACCOUNT=
```


---

## Windows install

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544");
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/BartSte/dotfiles-windows/master/dotfiles-windows/initialize.ps1'))
```

Then:

```powershell
$HOME/dotfiles-windows/main.ps1
```

---

## Dotfiles (cross‑platform)

Contains static dotfiles used by other layers. You typically don’t clone this directly.

### Neovim (`dotfiles/nvim`)

- `dotfiles/nvim/lua`:
  - `helpers`: helper functions
  - `plugins`: lazy.nvim plugins
  - `config`: plugin config
- `dotfiles/nvim/vim`: vimscript plugin config
- `dotfiles/nvim/plugin`: non‑plugin config loaded before `after/plugin`
- `dotfiles/nvim/after/plugin`: non‑plugin config
- `dotfiles/nvim/after/ftplugin`: filetype‑specific config

---

## Linux common (dotfiles-linux)

General Linux config shared by all distros (zsh, tmux, git, nvim, scripts, etc.).

### Project worktrees

The Arch setup creates `~/code/worktrees`. From a Git project, run `tsp-wt BRANCH`
to open that branch in its own worktree and tmux session. For example,
`tsp-wt feature/login` creates `~/code/worktrees/PROJECT--feature-login` when the
branch is new. Pass a project path as a second argument when you are elsewhere.

`prefix + f` opens one picker with project checkouts, managed
worktrees, and local branches of the current session's project that are not
checked out in any worktree. Press Enter to open a project or worktree. Select
an available branch and press `Ctrl-A` to create its worktree, or type a new
branch name in the search field with no match and press `Ctrl-A`. Press `Ctrl-X` to remove a
selected managed worktree. Git refuses removal if the worktree has changes.
Removing a worktree does not delete its branch.

`prefix + X` closes a session and keeps its worktree. `prefix + D` removes the
current session's worktree and closes the session. Both removal actions are
limited to linked worktrees directly under `~/code/worktrees`.

---

## Arch layer (dotfiles-arch)

Arch‑specific modules (pacman/aur, sway/waybar/kmonad, DNS/firewall, VPN, systemd units).  
Also contains **mutt**, **khal**, and **khalorg**.

---

## VPN (Arch layer)

VPN service: **Proton VPN CLI** (`proton-vpn-cli`).

---

## Raspberry Pi layer (dotfiles-pi)

Debian/RPi specific packages (apt), Tailscale, moltbot, etc.

---

## Mutt (Arch layer)

Two accounts (personal/work) are configured via a single `muttrc` using `MICROSOFT_ACCOUNT`.
Credentials are fetched via `rbw`/`bw-cli-get`.

Paths are now under:
- `~/dotfiles-arch/mutt/*`

---

## khal & khalorg (Arch layer)

Calendar setup for office calendar using vdirsyncer + khal + khalorg.

Paths are now under:
- `~/dotfiles-arch/khal/*`
- `~/dotfiles-arch/khalorg/*`

---

## Aliases (bare repos)

These are defined in `dotfiles-linux/zsh/git.zsh`:

- `base` / `bases`
- `lin` / `lins`
- `linarch` / `linarchs`
- `linpi` / `linpis`
- `dot` / `dots` / `dotu`

## Main vs Auth

- **main**: non‑interactive setup (safe to run in CI).
- **auth**: interactive steps (logins, tokens, pairing). Run manually.

## Notes

- If a module requires authentication or interactive steps, keep those in `auth` files.
- Secrets should live in **rbw** (never in the repos).
