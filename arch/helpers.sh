install_yay() {
    local dir="$1"
    git clone https://aur.archlinux.org/yay.git "$dir"
    old_dir=$(pwd)
    cd "$dir" || exit
    makepkg -si --noconfirm
    cd "$old_dir" || exit
    rm -rf "$dir"
}
