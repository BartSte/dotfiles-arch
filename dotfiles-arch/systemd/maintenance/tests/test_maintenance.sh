#!/usr/bin/env bash
set -euo pipefail

directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
source "$directory/libexec/pacman-args.sh"
source "$directory/libexec/packages"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

validate_pacman_args -S --needed --asdeps --noconfirm --config /etc/pacman.conf -- example/libfoo || fail 'Valid dependency install rejected'
validate_pacman_args --database --asdeps --config /etc/pacman.conf -- libfoo || fail 'Valid reason change rejected'
archive="$test_root/package with spaces.pkg.tar.zst"
touch "$archive"
validate_pacman_args -U --noconfirm --config /etc/pacman.conf -- "$archive" || fail 'Valid local package rejected'
for option in --root --hookdir --dbpath --overwrite --sysroot --assume-installed --noscriptlet --disable-sandbox; do
    if validate_pacman_args -S "$option" /tmp -- example; then fail "Dangerous option accepted: $option"; fi
done
if validate_pacman_args -S --config /tmp/pacman.conf -- example; then fail 'Alternate config accepted'; fi
if validate_pacman_args -R -- example; then fail 'Removal accepted'; fi
if validate_pacman_args -U -- /etc/passwd; then fail 'Non-package file accepted'; fi
if validate_pacman_args -S -- --overwrite; then fail 'Option accepted as a target'; fi
if validate_pacman_args -S; then fail 'Empty transaction accepted'; fi
if validate_pacman_args; then fail 'Empty input accepted'; fi

# A news gate or pacman failure must stop the official upgrade immediately.
informant() { printf 'news\n' >> "$test_root/order"; return "${news_result:-0}"; }
pacman() { printf 'pacman:%s\n' "$*" >> "$test_root/order"; return "${pacman_result:-0}"; }
find() { :; }
uname() { printf 'test-kernel\n'; }
news_result=1
if update_packages > "$test_root/output" 2>&1; then fail 'Unread news did not block the upgrade'; fi
[[ $(cat "$test_root/order") == news ]] || fail 'Pacman ran despite unread news'
news_result=0
pacman_result=7
if update_packages > "$test_root/output" 2>&1; then fail 'Pacman failure was ignored'; fi
if rg -q 'RESULT official-packages: success' "$test_root/output"; then fail 'Failed upgrade reported success'; fi
pacman_result=0
update_packages > "$test_root/output" 2>&1
rg -q 'pacman:-Syu --noconfirm' "$test_root/order" || fail 'Full unattended upgrade was not used'

# Exercise user orchestration with fake tools; no packages or plugins change.
mkdir -p "$test_root/bin" "$test_root/state with spaces"
export MAINTENANCE_TEST_LOG="$test_root/tool-log"
cat > "$test_root/bin/yay" <<'EOF'
#!/usr/bin/env bash
printf 'yay:%s\n' "$*" >> "$MAINTENANCE_TEST_LOG"
exit "${YAY_TEST_RESULT:-0}"
EOF
cat > "$test_root/bin/nvim" <<'EOF'
#!/usr/bin/env bash
printf 'nvim:%s\n' "$*" >> "$MAINTENANCE_TEST_LOG"
exit "${NVIM_TEST_RESULT:-0}"
EOF
chmod +x "$test_root/bin/"*
export PATH="$test_root/bin:$PATH"
export XDG_STATE_HOME="$test_root/state with spaces"
if [[ $EUID -eq 0 ]]; then
    printf 'SKIP: user orchestration tests require a non-root test account.\n'
else
    bash "$directory/libexec/user-updates" > "$test_root/output" 2>&1 || fail 'Normal user update failed'
    rg -q 'yay:-Sua --noconfirm' "$MAINTENANCE_TEST_LOG" || fail 'AUR-only update missing'
    rg -q -- '--pacman /usr/local/libexec/dotfiles-maintenance/aur-pacman' "$MAINTENANCE_TEST_LOG" || fail 'Restricted install helper missing'
    rg -q 'nvim:--headless -i NONE' "$MAINTENANCE_TEST_LOG" || fail 'Headless Neovim update missing'
    export YAY_TEST_RESULT=7
    if bash "$directory/libexec/user-updates" > "$test_root/output" 2>&1; then fail 'AUR failure was ignored'; fi
    rg -q 'RESULT neovim: success' "$test_root/output" || fail 'AUR failure prevented the independent Neovim update'
    export YAY_TEST_RESULT=0 NVIM_TEST_RESULT=9
    if bash "$directory/libexec/user-updates" > "$test_root/output" 2>&1; then fail 'Neovim failure was ignored'; fi
    rg -q 'failed 9' "$XDG_STATE_HOME/dotfiles-maintenance/neovim.result" || fail 'Neovim failure was not recorded'
    exec 8>"$XDG_STATE_HOME/dotfiles-maintenance/update.lock"
    flock -n 8
    if bash "$directory/libexec/user-updates" > "$test_root/output" 2>&1; then fail 'Overlapping user update was allowed'; fi
    flock -u 8
fi

# Verify units against existing test executable paths, without installing them.
mkdir -p "$test_root/units"
for unit in "$directory/units/"*; do
    while IFS= read -r line; do
        printf '%s\n' "${line//\/usr\/local\/libexec\/dotfiles-maintenance/$directory/libexec}"
    done < "$unit" > "$test_root/units/$(basename "$unit")"
done
systemd-analyze verify "$test_root/units/"*
printf 'testuser ALL=(root) NOPASSWD: /usr/local/libexec/dotfiles-maintenance/aur-pacman\n' > "$test_root/sudoers"
visudo -cf "$test_root/sudoers"
CI=true "$directory/main"
printf 'PASS: argument restrictions, news gate, failures, locks, units, sudoers, and CI guard\n'
