link_config() {
    local source_dir destination_dir files file destination file files
    source_dir=~/dotfiles/qutebrowser
    destination_dir=~/.config/qutebrowser

    lg "Ensure $destination_dir exists"
    mkdir -p "$destination_dir"

    echo "Link all files from $source_dir to $destination_dir"
    files=$(find $source_dir -maxdepth 1 -type f -exec basename {} \;)
    for file in $files; do
        source="$source_dir/$file"
        destination="$destination_dir/$file"
        lg "Link $source to $destination"
        ln -sf "$source" "$destination"
    done
}

link_bookmarks() {
    config_dir="$HOME/dotfiles-secret/dropbox/Config"
    [[ -d "$config_dir" ]] || config_dir="$HOME/dropbox/Config"

    target_urls="$config_dir/urls-$(hostname)"
    target_quickmarks="$config_dir/quickmarks-$(hostname)"

    link_urls="$HOME/.config/qutebrowser/bookmarks/urls"
    link_quickmarks="$HOME/.config/qutebrowser/quickmarks"

    lg "Create links from $target_urls to $link_urls"
    lg "Create links from $target_quickmarks to $link_quickmarks"

    mkdir -p "$(dirname "$link_urls")"
    mkdir -p "$(dirname "$link_quickmarks")"

    [[ -f "$link_urls" ]] || touch "$link_urls"
    [[ -f "$link_quickmarks" ]] || touch "$link_quickmarks"

    ln -sf "$target_urls" "$link_urls"
    ln -sf "$target_quickmarks" "$link_quickmarks"
}

link_userscripts() {
    source_dir="$HOME/dotfiles-secret/dropbox/Config/tampermonkey"
    [[ -d "$source_dir" ]] || source_dir="$HOME/dropbox/Config/tampermonkey"
    destination_dir="$HOME/.config/qutebrowser/greasemonkey"

    lg "Ensure $destination_dir exists"
    mkdir -p "$destination_dir"

    lg "Ensure $source_dir exists, in case dropbox is setup later."
    mkdir -p "$source_dir"

    lg "Link all files from $source_dir to $destination_dir"
    files=$(find "$source_dir" -maxdepth 1 -type f -exec basename {} \;)
    for file in $files; do
        source="$source_dir/$file"
        destination="$destination_dir/$file"
        lg "Link $source to $destination"
        ln -sf "$source" "$destination"
    done
}
