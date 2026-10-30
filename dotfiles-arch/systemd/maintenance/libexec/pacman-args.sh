#!/usr/bin/bash

# Validate the small set of mutations yay needs. In particular, reject alternate
# roots, databases, hooks, configuration files, removals, and overwrite flags.
validate_pacman_args() {
    local argument operation='' targets=false count=0
    while [[ $# -gt 0 ]]; do
        argument=$1
        shift
        if [[ $targets == true ]]; then
            [[ -n $argument && $argument != -* ]] || return 1
            if [[ $operation == upgrade ]]; then
                [[ $argument == /* && $argument == *.pkg.tar.* && -f $argument ]] || return 1
            else
                [[ $argument =~ ^[a-zA-Z0-9_@.+:/=\<\>~-]+$ ]] || return 1
            fi
            count=$((count + 1))
            continue
        fi
        case "$argument" in
            -S|--sync) [[ -z $operation ]] || return 1; operation=sync ;;
            -U|--upgrade) [[ -z $operation ]] || return 1; operation=upgrade ;;
            -D|--database) [[ -z $operation ]] || return 1; operation=database ;;
            --asdeps|--asexplicit|--needed|--noconfirm|--noprogressbar) ;;
            --config)
                [[ $# -gt 0 && $1 == /etc/pacman.conf ]] || return 1
                shift
                ;;
            --color)
                [[ $# -gt 0 && $1 =~ ^(auto|always|never)$ ]] || return 1
                shift
                ;;
            --) [[ -n $operation ]] || return 1; targets=true ;;
            *) return 1 ;;
        esac
    done
    [[ $targets == true && $count -gt 0 ]]
}
