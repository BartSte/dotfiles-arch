install_yay() {
    local dir="$1"
    git clone https://aur.archlinux.org/yay.git "$dir"
    local old_dir
    old_dir=$(pwd)
    # makepkg refuses to run as root; delegate to a non-root user when needed.
    # In CI the container runs as root, so we hand off to 'builduser' which has
    # NOPASSWD sudo so it can call 'sudo pacman' during makepkg -si.
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        local build_user="${SUDO_USER:-builduser}"
        chown -R "${build_user}": "$dir"
        cd "$dir" || exit
        su "${build_user}" -c "cd '$dir' && makepkg -si --noconfirm"
        cd "$old_dir" || exit
    else
        cd "$dir" || exit
        makepkg -si --noconfirm
        cd "$old_dir" || exit
    fi
    rm -rf "$dir"
}
