#!/usr/bin/env bash
# Install tmux, TPM, and this repository's tmux configuration.
#
# This script can be invoked from any working directory.  It finds the
# configuration relative to this file, then links it to ~/.tmux.conf.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
config_file="$script_dir/.tmux.conf"
tpm_dir="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.tmux/plugins/tpm}"

if [[ ! -f "$config_file" ]]; then
  printf 'Cannot find tmux configuration at %s\\n' "$config_file" >&2
  exit 1
fi

run_as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    printf 'Administrator privileges are required to install packages.\\n' >&2
    exit 1
  fi
}

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    run_as_root apt-get update
    run_as_root apt-get install -y tmux git bc
  elif command -v dnf >/dev/null 2>&1; then
    run_as_root dnf install -y tmux git bc
  elif command -v yum >/dev/null 2>&1; then
    run_as_root yum install -y tmux git bc
  elif command -v pacman >/dev/null 2>&1; then
    run_as_root pacman -Sy --needed --noconfirm tmux git bc
  elif command -v zypper >/dev/null 2>&1; then
    run_as_root zypper --non-interactive install tmux git bc
  elif command -v apk >/dev/null 2>&1; then
    run_as_root apk add tmux git bc
  elif command -v brew >/dev/null 2>&1; then
    brew install tmux git bc
  else
    printf 'No supported package manager found. Install tmux, git, and bc, then rerun this script.\\n' >&2
    exit 1
  fi
}

missing=()
command -v tmux >/dev/null 2>&1 || missing+=(tmux)
command -v git >/dev/null 2>&1 || missing+=(git)
command -v bc >/dev/null 2>&1 || missing+=(bc)

if (( ${#missing[@]} > 0 )); then
  printf 'Installing missing dependencies: %s\\n' "${missing[*]}"
  install_packages
fi

mkdir -p "$(dirname -- "$tpm_dir")"
if [[ -d "$tpm_dir/.git" ]]; then
  git -C "$tpm_dir" pull --ff-only
elif [[ -e "$tpm_dir" ]]; then
  printf 'TPM path exists but is not a Git checkout: %s\\n' "$tpm_dir" >&2
  exit 1
else
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
fi

target="$HOME/.tmux.conf"
if [[ -e "$target" && ! -L "$target" ]]; then
  backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  mv -- "$target" "$backup"
  printf 'Backed up existing config to %s\\n' "$backup"
fi
ln -sfn "$config_file" "$target"

if [[ -n "${TMUX:-}" ]]; then
  tmux source-file "$target"
  printf 'Reloaded tmux configuration in the current server.\\n'
else
  printf 'Tmux configuration installed at %s. Start tmux to load it.\\n' "$target"
fi

printf 'TPM installed at %s. In tmux, press prefix + I to install configured plugins.\\n' "$tpm_dir"
