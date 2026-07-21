#!/usr/bin/env bash

set -euo pipefail

: "${HOME:?HOME must be set}"

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_bashrc="$script_dir/.bashrcMin"
home_bashrc="$HOME/.bashrc"
backup_bashrc="$HOME/.bashrcorigin"

if [[ ! -f "$source_bashrc" ]]; then
    printf 'Error: source bashrc not found: %s\n' "$source_bashrc" >&2
    exit 1
fi

# A second run after a successful installation should not replace the backup.
if [[ -f "$home_bashrc" && ! -L "$home_bashrc" ]] && cmp -s -- "$source_bashrc" "$home_bashrc"; then
    printf 'Already installed: %s matches %s\n' "$home_bashrc" "$source_bashrc"
    exit 0
fi

if [[ -e "$home_bashrc" || -L "$home_bashrc" ]]; then
    if [[ -e "$backup_bashrc" || -L "$backup_bashrc" ]]; then
        printf 'Error: backup already exists: %s\n' "$backup_bashrc" >&2
        printf 'Move or remove it before running this installer again.\n' >&2
        exit 1
    fi

    mv -- "$home_bashrc" "$backup_bashrc"
    printf 'Backed up %s to %s\n' "$home_bashrc" "$backup_bashrc"
fi

cp -- "$source_bashrc" "$home_bashrc"
printf 'Copied %s to %s\n' "$source_bashrc" "$home_bashrc"
