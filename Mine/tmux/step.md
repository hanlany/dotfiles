# tmux setup

## Install

Run the installer from any directory:

```bash
/path/to/dotfiles/Mine/tmux/install.sh
```

The script:

- Installs `tmux`, `git`, and `bc` when they are missing. It supports APT, DNF, YUM, Pacman, Zypper, APK, and Homebrew.
- Installs or updates [TPM](https://github.com/tmux-plugins/tpm) at `~/.tmux/plugins/tpm`.
- Links this repository's `tmux/.tmux.conf` to `~/.tmux.conf`.
- Reloads the configuration immediately when the script is run inside a tmux session.

After starting tmux, install the configured TPM plugins with `prefix` then `I` (capital `i`). The default prefix is `Ctrl-b` unless you change it elsewhere.

## Things to be aware of

- The installed `~/.tmux.conf` is a symbolic link to this repository. Keep the repository at the same path; rerun the installer after moving it.
- If `~/.tmux.conf` already exists as a regular file, the installer saves it as `~/.tmux.conf.backup.<timestamp>` before creating the link.
- The configuration enables mouse support, vi-style copy mode, a 9,999-line pane history, and Vim-aware `Ctrl-h`, `Ctrl-j`, `Ctrl-k`, and `Ctrl-l` pane navigation.
- TPM itself is installed automatically, but its configured plugins are installed only after pressing `prefix` then `I` inside tmux. Use `prefix` then `U` later to update them.
- Package installation may ask for your administrator password. On an unsupported operating system, install `tmux`, `git`, and `bc` manually, then rerun the script.
